//
//  Message+Extension.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 12/27/24.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
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

    internal func logLine(
        level: Logging.Logger.Level,
        label: String,
        file: String,
        function: String
    ) -> String {
        var tokens = [String]()

        tokens.append(Self.options.timeStamp)

        if Self.options.contains(.processID) {
            tokens.append("<\(ProcessInfo.processInfo.processIdentifier)>")
        }
        
        if Self.options.contains(.threadColumn) {
            // threadIdWith3Digits will be no more than 4 chars, so we clamp this value to make it more tabular and easy to read
            let infoAndThreadColumn = "<\(level.levelString) \(Thread.threadIdWith3Digits)>"
            tokens.append(infoAndThreadColumn.padding(toLength: 8, withPad: " ", startingAt: 0))
        }

        if !label.isEmpty {
            if Self.options.contains(.swiftTypeName) {
                tokens.append(label.appending(".".appending(function)))
            }
            else if Self.options.contains(.functionName) {
                tokens.append(".".appending(function))
            }
        }

        tokens.append("\(self)\n")
        var message = ""
        tokens.enumerated().forEach { item in
            if item.offset == 0 {
                message += item.element
            }
            else if (item.offset == tokens.count - 1) {
                message += "  |  " + item.element
            }
            else {
                message += " | " + item.element
            }
        }
        return message
    }
}
