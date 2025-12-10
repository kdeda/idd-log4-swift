//
//  Message+Extension.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 12/27/24.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
//

import Foundation

// MARK: - Date (Internal) -

extension Date {
    /**
     Configuration
     -IDDLog.timeStampFormat compact

     default is 'standard'
     valid entries are 'standard' and 'compact'
     */
    internal static let timeStampFormat_compact = {
        let processIDFormat = UserDefaults.standard.string(forKey: "IDDLog.timeStampFormat") ?? "standard"
        if processIDFormat == "compact" {
            return true
        }
        return false
    }()

    internal static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()

        if Self.timeStampFormat_compact {
            dateFormatter.dateFormat = "HH:mm:ss.SSS"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        }
        dateFormatter.locale = Locale.init(identifier: "en_US_POSIX")
        return dateFormatter
    }()

    internal static var timeStamp: String {
        dateFormatter.string(from: Date())
    }
}

// MARK: - Logging.Logger.Message (Internal) -

extension Logging.Logger.Message {
    /**
     Configuration
     -IDDLog.processIDFormat none

     default is 'standard'
     valid entries are 'standard' and 'none'
     */
    internal static let processIDFormat_none = {
        let processIDFormat = UserDefaults.standard.string(forKey: "IDDLog.processIDFormat") ?? "standard"
        if processIDFormat == "none" {
            return true
        }
        return false
    }()

    /**
     Configuration
     -IDDLog.callSiteFormat functionOnly

     default is 'standard'
     valid entries are 'standard' and 'functionOnly'
     */
    internal static let callSiteFormat_functionOnly = {
        let processIDFormat = UserDefaults.standard.string(forKey: "IDDLog.callSiteFormat") ?? "standard"
        if processIDFormat == "functionOnly" {
            return true
        }
        return false
    }()

    internal func logLine(
        level: Logging.Logger.Level,
        label: String,
        file: String,
        function: String
    ) -> String {
        var message = Date.timeStamp

        if !Self.processIDFormat_none {
            message += " | <\(ProcessInfo.processInfo.processIdentifier)>"
        }
        
        message += " | <\(level.levelString) \(Thread.threadIdWith3Digits)>".padding(toLength: 10, withPad: " ", startingAt: 0)

        if !label.isEmpty {
            if Self.callSiteFormat_functionOnly {
                message += " | .\(function) "
            } else {
                message += " | \(label).\(function) "
            }
        }
        
        if !label.isEmpty {
            message += " |  \(self)\n" // extra space
        } else {
            message += " | \(self)\n"
        }
        
        return message
    }
}
