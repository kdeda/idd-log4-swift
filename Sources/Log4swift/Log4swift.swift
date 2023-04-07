//
//  Log4swift.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2023 id-design, inc. All rights reserved.
//

import Logging
import Foundation

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

        let level: String = {
            if let rv = UserDefaults.standard.string(forKey: identifier) {
                return rv
            }
            // Foobar.Foo class names
            //
            var derivedShortClassName = "UnknownClassName"
            let tokens = identifier.components(separatedBy: ".")

            if tokens.count > 1 {
                // Foobar.Foo type class names
                //
                derivedShortClassName = tokens[tokens.count - 1]
                return UserDefaults.standard.string(forKey: derivedShortClassName) ?? ""
            } else {
                // Foobar<Foo> type class names
                //
                let tokens = identifier.components(separatedBy: "<")

                if tokens.count > 1 {
                    derivedShortClassName = tokens[0]
                    return UserDefaults.standard.string(forKey: derivedShortClassName) ?? ""
                }
            }
            return ""
        }()

        var logger = Logger(label: identifier)
        if level == "D" {
            logger.logLevel = .debug
        } else if level == "T" {
            logger.logLevel = .trace
        }

        loggers[identifier] = logger
        return logger
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
