//
//  Logging.LogEvent+Extension.swift
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

/**
 by adding | as column separators we make the logs easier to visually and programatically parse.
 by trying to keep the basic columns of the same width it helps a bit more with visual feed back
 it appears as if you are reading  spread sheet

 threadIdWith3Digits will be at most 6 chars long, where 3 are the thread digits,
 without clamping, its column width would vary on a heavy threaded app, so we clamp it to a max of 3 digits for the thread number

 at this point the logs should be fairly formatted but we do more
 if you use bash you can use the amazing cut command to cut a line by tokens
 too bad it does not handle more than one char.

 copy paste a bunch of log lines and
 pbpaste | cut -d "|" -f 5
 The abouve command will discard the first 4 columns and display column 5 the last
 pbpaste | cut -d "|" -f 5 | grep filePath | sort
 */
extension Logging.LogEvent {
    internal static let options = ConfigOptions.optionsFromUserDefaults
    internal static let columnSeparator = "  |  "

    /**
     Will build the real string to log as we want it
     */
    internal func logLine(label: String) -> String {
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

        tokens.append("\(self.message)\n")
        return tokens.joined(separator: Self.columnSeparator)
    }
}
