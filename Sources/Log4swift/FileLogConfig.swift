//
//  FileLogConfig.swift
//  Log4swift
//
//  Created by Klajd Deda on 9/30/24.
//  Copyright (C) 1997-2024 Klajd Deda. All rights reserved.
//

import Foundation

fileprivate extension Date {
    static let logFileDate: DateFormatter = {
        let rv = DateFormatter()

        rv.timeZone = TimeZone(abbreviation: "UTC")
        rv.dateFormat = "yyyy_MM_dd"
        return rv
    }()

    // positive number if some time has elapsed since now
    //
    var elapsedTimeInSeconds: Double {
        (-self.timeIntervalSinceNow)
    }

    var secondsTillMidnight: Int {
        let calendarDate = Calendar.current.dateComponents([.day, .year, .month, .hour, .minute, .second], from: self)
        let hour = calendarDate.hour ?? 0
        let minute = calendarDate.minute ?? 0
        let second = calendarDate.second ?? 1
        // print("year: \(calendarDate.year), month: \(calendarDate.month), day: \(calendarDate.day), hour: \(hour), minute: \(minute), second: \(second)")

        let rv = 24 * 3600 - hour * 3600 - minute * 60 - second
        // print("secondsTillMidnight: \(rv)")
        return rv
    }

    /**
     We do not want to create any new log entry until the new day starts
     We just ant to roll over the day number
     eg: '2024_09_29' -> '2024_09_30' -> '2024_10_01' etc
     */
    func isNewDay(_ secondsTillMidnight: Int) -> Bool {
        let diff = secondsTillMidnight - Int(self.elapsedTimeInSeconds)
        // print("diff: \(diff)")

        if diff < 0 {
            // we are now on th next day
            return true
        }
        return false
    }
}

/**
 Models a rotating file log
 We do not want to create any new log entry until the new day starts
 We just ant to roll over the day number
 eg: '2024\_09\_29' -> '2024\_09\_30' -> '2024\_10\_01' etc
 */
public final class FileLogConfig {
    enum FileHandlerOutputStream: Error {
        case couldNotCreateFile
    }

    // eg: /Library/Vapor/ChefTimeServer/logs
    private var logRootURL: URL

    // eg: 'WhatSize'
    private var prefix: String
    // eg: 'vapor'
    private var suffix: String
    private var daysToKeep: Int
    private var date: Date = .distantPast
    private var secondsTillMidnight: Int = 0
    private var fileHandle: FileHandle

    /**
     This will be combined
     ${logRootURL}/${suffix}\_${date:\_yyyy\_mm\_ddd}\_${prefix}.log
     */
    public var fileURL: URL
    private let encoding: String.Encoding = .utf8

    /**
     what happens if two processes use the same file for writing
     hum, they might collide
     */
    public init(logRootURL: URL, appPrefix: String, appSuffix: String, daysToKeep: Int = 30) throws {
        if !FileManager.default.fileExists(atPath: logRootURL.path) {
            try FileManager.default.createDirectory(at: logRootURL, withIntermediateDirectories: true)
        }

        self.logRootURL = logRootURL
        self.prefix = appPrefix
        self.suffix = appSuffix
        self.daysToKeep = daysToKeep

        self.date = Date()
        self.secondsTillMidnight = Date().secondsTillMidnight

        func createFileURL(_ date: Date, _ appPrefix: String, _ appSuffix: String) -> URL {
            let tokens: [String] = [appPrefix, Date.logFileDate.string(from: date), appSuffix]
            let fileName =  tokens.filter({ !$0.isEmpty }).joined(separator: "_").appending(".log")
            let fileURL = logRootURL.appendingPathComponent(fileName)

            // TODO:
            // Not sure i want this
            //
            //  if FileManager.default.fileExists(atPath: fileURL.path) {
            //      /**
            //       rename the existing one
            //       will tell us if we crash or stop start
            //       */
            //      let secondsSinceReference = Int(date.timeIntervalSinceReferenceDate)
            //      // print("secondsSinceReference: \(secondsSinceReference)")
            //
            //      let destination = fileURL.appendingPathExtension("\(secondsSinceReference)")
            //      try? FileManager.default.moveItem(at: fileURL, to: destination)
            //  }
            return fileURL
        }
        let fileURL = createFileURL(Date(), appPrefix, appSuffix)

        self.fileURL = fileURL
        self.fileHandle = try {
            if !FileManager.default.fileExists(atPath: fileURL.path) {
                guard FileManager.default.createFile(atPath: fileURL.path, contents: nil, attributes: nil)
                else {
                    throw FileHandlerOutputStream.couldNotCreateFile
                }
            }
            return try FileHandle(forWritingTo: fileURL)
        }()
        self.fileHandle.seekToEndOfFile()
    }

    func write(_ string: String) {
        if let newConfig = self.newConfig {
            // we are now on the next day and new log files.
            // Log4swift.shared.resetLoggers()

            self.date = newConfig.date
            self.secondsTillMidnight = newConfig.secondsTillMidnight
            self.fileHandle = newConfig.fileHandle
            self.fileURL = newConfig.fileURL
        }

        if let data = string.data(using: encoding) {
            fileHandle.write(data)
        }
    }

    /**
     Will return nil if we have it configured such as daysToKeep == 0
     This is supposed to be very very fast.
     */
    private var newConfig: Self? {
        guard daysToKeep != 0
        else { return .none }

        guard date.isNewDay(secondsTillMidnight)
        else { return .none }

        return try? Self(logRootURL: logRootURL, appPrefix: prefix, appSuffix: suffix, daysToKeep: daysToKeep)
    }
}
