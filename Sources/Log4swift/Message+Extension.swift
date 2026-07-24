//
//  Message+Extension.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 12/27/24.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation

// MARK: - ConfigOptions (timeStamp) -

extension ConfigOptions {
    internal static let defaultTimeStamp_: DateFormatter = {
        let rv = DateFormatter()

        rv.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        rv.locale = Locale.init(identifier: "en_US_POSIX")
        return rv
    }()

    internal static let compactTimeStamp_: DateFormatter = {
        let rv = DateFormatter()

        rv.dateFormat = "HH:mm:ss.SSS"
        rv.locale = Locale.init(identifier: "en_US_POSIX")
        return rv
    }()

    var timeStamp: String {
        if contains(.compactTimeStamp) {
            return Self.compactTimeStamp_.string(from: Date())
        }
        return Self.defaultTimeStamp_.string(from: Date())
    }
}

// MARK: - Logging.Logger.Message (Internal) -

extension Logging.Logger.Message {
    internal static let options = ConfigOptions.optionsFromUserDefaults

    /**
     Will build the real string to log
     */
    internal func logLine(
        level: Logging.Logger.Level,
        label: String,
        file: String,
        function: String,
        line: UInt
    ) -> String {
        var tokens = [String]()

        tokens.append(Self.options.timeStamp)

        /// process info
        if Self.options.contains(.processID) {
            tokens.append("<\(ProcessInfo.processInfo.processIdentifier)>")
        }

        /// thread info
        if Self.options.contains(.threadColumn) {
            // threadIdWith3Digits will be no more than 4 chars, so we clamp this value to make it more tabular and easy to read
            let infoAndThreadColumn = "<\(level.levelString) \(Thread.threadIdWith3Digits)>"
            tokens.append(infoAndThreadColumn.padding(toLength: 8, withPad: " ", startingAt: 0))
        }

        /// type, function, source line info
        if !label.isEmpty {
            if Self.options.contains(.fileName) && !file.isEmpty {
                tokens.append(file
                    .appending(":")
                    .appending("\(line)")
                )
            }
            if Self.options.contains(.swiftTypeName) {
                tokens.append(label)
            }
            if Self.options.contains(.functionName) {
                tokens.append(function)
            }
        }

        tokens.append("\(self)\n")
        return tokens.joined(separator: "  |  ")
    }
}
