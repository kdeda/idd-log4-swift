//
//  Log4swift.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2023 id-design, inc. All rights reserved.
//

import Foundation
import Logging

public final class Log4swift {
    private static let shared = Log4swift()
    private var loggers = [String: Logger]()
    private let workerLock = DispatchSemaphore(value: 1)

    private func getLogger(_ identifier: String) -> Logger {
        workerLock.wait()
        defer { workerLock.signal() }

        if let rv = loggers[identifier] {
            return rv
        }

        let logInfo: (logID: String, level: String) = {
            // full class name
            // ie: `IDDList.IDDList<IDDFolderScan.NodeEntry>`
            //
            if let rv = UserDefaults.standard.string(forKey: identifier) {
                return (logID: identifier, level: rv)
            }
            
            // try to reme all crap after the long name
            // ie: `IDDList.IDDList<IDDFolderScan.NodeEntry>`
            // should become 'IDDList.IDDList'
            //
            let tokens = identifier.components(separatedBy: "<")

            if tokens.count > 0 {
                let shortcClassName = tokens[0]
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
            logger.log(level: .error, "Using 'I', info level for: '\(logInfo.logID)'")
        }

        loggers[identifier] = logger
        return logger
    }

    /**
     If you define the -standardLog true at the start of your application, all
     log lessages will go to the Console (under stdout).
     Otherwise if the app is running in user space they will go to ~/Library/Logs/${appName}.log
     but if the app is running as root the logs will go to /Library/Logs/${appName}.log
     
     Any extra config has to be done manually.
     */
    static public func configure(appName: String) {
        if UserDefaults.standard.bool(forKey: "standardLog") {
            LoggingSystem.bootstrap { label in
                ConsoleHandler(label: label)
            }
        } else {
            let home: URL = {
                let uid = getuid()
                guard uid != 0
                else { return URL.init(fileURLWithPath: "/") }
                
                return URL.init(fileURLWithPath: NSHomeDirectory())
            }()
            
            let fileURL = home.appendingPathComponent("Library/Logs").appendingPathComponent(appName).appendingPathExtension("log")
            let fileLogger = try? FileLogger(to: fileURL)
            
            LoggingSystem.bootstrap { label in
                FileLogHandler(label: label, fileLogger: fileLogger!)
            }
        }
    }
    
    /**
     This is very fast, 3 seconds for 1 million look ups
     */
    static public subscript(identifier: String) -> Logger {
        shared.getLogger(identifier)
    }

    static public subscript<T>(type: T.Type) -> Logger {
        shared.getLogger(String(reflecting: type))
    }
}
