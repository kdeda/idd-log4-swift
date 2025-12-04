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
        var tokens: [String] = []

        func appendTimeStamp() {
            tokens.append(Date.timeStamp)
        }

        func appendProcessID() {
            if !Self.processIDFormat_none {
                tokens.append("<\(ProcessInfo.processInfo.processIdentifier)>")
            }
        }

        func appendInfoAndThread() {
            let infoAndThread = "<\(level.levelString) \(Thread.threadIdWith3Digits)>".padding(toLength: 10, withPad: " ", startingAt: 0)
            tokens.append(infoAndThread)
        }

        func appendCallSite() {
            if !label.isEmpty {
                if Self.callSiteFormat_functionOnly {
                    tokens.append(".\(function) ")
                } else {
                    tokens.append("\(label).\(function) ")
                }
            }
        }

        func appendMessage() {
            if !label.isEmpty {
                tokens.append(" \(self)\n")
            } else {
                tokens.append("\(self)\n")
            }
        }

        appendTimeStamp()
        appendProcessID()
        appendInfoAndThread()
        appendCallSite()
        appendMessage()

        return tokens.joined(separator: " | ")
    }
}
