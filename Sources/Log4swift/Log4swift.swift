//
//  Log4swift.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
//

import Foundation
import Logging

public final class Log4swift {
    internal static let shared = Log4swift()
    private var loggers = [String: Logger]()
    private var fileLogConfig: FileLogConfig?
    private let workerLock = DispatchSemaphore(value: 1)
    private var printThisOnce = true

    /**
     The log identifier or logID should be the name of the type
     following Swift name spaces
     ie: `IDDList.IDDList<IDDFolderScan.NodeEntry>`
     or: `Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>`
     or: `WhatSize.DetailToolbarItem.State`

     When configuring for a generic type like `Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>` you have
     2 options to set the log level
     1. -`Swift.AsyncStream` D, for all inner types
     2. -`Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>` D, for just this inner type

     This is very fast, 3 seconds for 1 million look ups
     */
    private func getLogger(_ identifier: String) -> Logger {
        workerLock.wait()
        defer { workerLock.signal() }

        if let rv = loggers[identifier] {
            // we will get here for subsequent calls so the over head of this func is O(1)
            return rv
        }

        // DEDA DEBUG
        // fully qualified name space debuging ...
        //   if identifier == "Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>" {
        //       NSLog("Using 'I', info level for: '\(identifier)'")
        //   }
        let logInfo: (logID: String, level: String) = {
            if let rv = UserDefaults.standard.string(forKey: identifier) {
                // the exact full name space
                // ie: `Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>`
                return (logID: identifier, level: rv)
            }
            
            let tokens = identifier.components(separatedBy: "<")

            if tokens.count > 0 {
                let shortcClassName = tokens[0]
                // the generic name
                // ie: `Swift.AsyncStream`
                if let rv = UserDefaults.standard.string(forKey: shortcClassName) {
                    return (logID: shortcClassName, level: rv)
                }
            }
            return (logID: identifier, level: "")
        }()

        var logger = Logger(label: identifier)
        if logInfo.level == "D" {
            logger.logLevel = .debug
        } else if logInfo.level == "T" {
            logger.logLevel = .trace
        } else {
            if printThisOnce && !logInfo.logID.isEmpty {
                // print this once
                logger.log(level: .error, "Using 'I', info level for: '\(logInfo.logID)'")
                printThisOnce = false
            }
        }

        loggers[identifier] = logger
        return logger
    }

    fileprivate static let executable = {
        Bundle.main.executableURL?.lastPathComponent ?? ""
    }()

    /**
     Say we are using a new file.
     Reset all these cached loggers
     */
    internal func resetLoggers() {
        workerLock.wait()
        defer { workerLock.signal() }

        loggers.removeAll()
    }


    // MARK: - Public -

    /**
     This code supposed to support macOS, iOS and linux (close to macOS)
     If you define the -standardLog true at the start of your application, all
     log lessages will go to the Console (under stdout).
     Otherwise if the app is running in user space they will go to ~/Library/Logs/${appName}.log
     but if the app is running as root the logs will go to /Library/Logs/${appName}.log

     If the app is running in iOS we will use the ConsoleHandler, ie: the log messages in
     relase will go to the log stream and can be viewed using Console.app

     Any extra config has to be done manually.
     */
    static public func configure(fileLogConfig: FileLogConfig? = nil) {
        if UserDefaults.standard.bool(forKey: "standardLog") {
            LoggingSystem.bootstrap { label in
                ConsoleHandler(label: label)
            }
            return
        }
#if os(iOS)
        LoggingSystem.bootstrap { label in
            let adjustedLabel = {
                if !Self.executable.isEmpty {
                    // print("executable: '\(executable)'")

                    if label.isEmpty {
                        return executable
                    }
                    if label.hasPrefix(executable) {
                        return label
                    }
                    return executable + "." + label
                }
                return label
            }()
            return LoggingOSLog(label: adjustedLabel)
        }
#else
        guard let fileLogConfig = fileLogConfig
        else {
            LoggingSystem.bootstrap { label in
                ConsoleHandler(label: label)
            }
            return
        }

        Self.shared.fileLogConfig = fileLogConfig
        // assuming macOS, Linux and of course a valid logFile
        LoggingSystem.bootstrap { label in
            return FileLogHandler(label: label, fileLogConfig: fileLogConfig)
        }
#endif
    }

    /**
     Please define the names here with full name space.
     ie: 'IDDSwift.Process'
     */
    static public subscript(identifier: String) -> Logger {
        shared.getLogger(identifier)
    }

    /**
     Return the full name of the type the first chunk is the name space
     ie: 'Foundation.URL'
     ie: 'Swift.Array<WhatSize.SBItem>'
     */
    static public subscript<T>(type: T.Type) -> Logger {
        shared.getLogger(String(reflecting: type))
    }

    /**
     Convenience to dump just the message.
     */
    public static func log(_ message: String) {
        if UserDefaults.standard.bool(forKey: "standardLog") {
            fputs(message, stdout)
            return
        }
        guard let fileLogConfig = Self.shared.fileLogConfig
        else {
            fputs(message, stdout)
            return
        }
        fileLogConfig.write(message)
    }

}
