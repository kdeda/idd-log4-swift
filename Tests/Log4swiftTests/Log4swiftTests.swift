//
//  Log4swiftTests.swift
//  idd-swift
//
//  Created by Klajd Deda on 11/15/25.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
//

import Testing
import Foundation
import Logging
@testable import Log4swift

struct Log4swiftTests {
    /**
     Test the log to file.
     Create a config with a file
     Log using it
     Assert that the message we logged is there
     */
    @Test func testLogFile() throws {
        let home = URL.init(fileURLWithPath: NSHomeDirectory())
        let logRootURL = home.appendingPathComponent("Library/Logs/Log4swiftTest")

        // erase all previous logs
        if FileManager.default.fileExists(atPath: logRootURL.path) {
            try FileManager.default.removeItem(at: logRootURL)
        }

        let fileLogConfig = try FileLogConfig.init(logRootURL: logRootURL, appPrefix: "Test", appSuffix: "", daysToKeep: 30)

        if let readHandle = try? FileHandle(forReadingFrom: fileLogConfig.fileURL) {
            _ = try? readHandle.seekToEnd()
            let logMessages = [
                "Hello message1",
                "We are going to assert this"
            ]

            // configure it to use file
            LoggingSystem.bootstrap { label in
                FileLogHandler(label: label, fileLogConfig: fileLogConfig)
            }
            // log a message
            logMessages.forEach { logMessage in
                Log4swift[Self.self].info("\(logMessage)")
            }

            // assert
            let readMessages_ = String(data: readHandle.availableData, encoding: .utf8) ?? ""
            let readMessages = readMessages_.components(separatedBy: "\n")
                .compactMap { $0.isEmpty ? nil : $0 }

            let matched = readMessages.filter { readMessage in
                let message = logMessages.first { readMessage.hasSuffix($0) }
                return message != nil
            }

            Log4swift[Self.self].info("    matched.count: '\(matched.count)'")
            Log4swift[Self.self].info("logMessages.count: '\(logMessages.count)'")

            #expect(matched.count == logMessages.count)
        }
    }

    /**
     NO CONFIG
     ```
     2026-01-09 10:22:36.772 | <18395> | <E main> | Log4swiftTests.Log4swiftTests.getLogger(_:)  |  Using 'I', info level for: 'Log4swiftTests.Log4swiftTests'
     2026-01-09 10:22:36.772 | <18395> | <I main> | Log4swiftTests.Log4swiftTests.testConfigOptions()  |  Before creating InnerType
     2026-01-09 10:22:36.772 | <18395> | <I main> | Log4swiftTests.Log4swiftTests.(unknown context at $102b07f3c).(unknown context at $102b07f48).InnerType.init()  |  Created instance of InnerType
     2026-01-09 10:22:36.772 | <18395> | <I main> | Log4swiftTests.Log4swiftTests.testConfigOptions()  |  Completed
     ```
     */

    /**
     Log4swift.configureCompactSettings
     ```
     10:22:17.527 | <E main> | .getLogger(_:)  |  Using 'I', info level for: 'Log4swiftTests.Log4swiftTests'
     10:22:17.527 | <I main> | .testConfigOptions()  |  Before creating InnerType
     10:22:17.527 | <I main> | .init()  |  Created instance of InnerType
     10:22:17.527 | <I main> | .testConfigOptions()  |  Completed
     ```
     */
    /**
     Log4swift.configureConsoleMode
     ```
     10:21:59.142  |  Before creating InnerType
     10:21:59.144  |  Created instance of InnerType
     10:21:59.144  |  Completed
     ```
     */
    @Test func testConfigOptions() throws {
        let home = URL.init(fileURLWithPath: NSHomeDirectory())
        let logRootURL = home.appendingPathComponent("Library/Logs/Log4swift")
        let fileConfig: FileLogConfig? = try? .init(logRootURL: logRootURL, appPrefix: "Log4swift", appSuffix: "", daysToKeep: 30)

        // Log4swift.configureCompactSettings()
        // Log4swift.configureConsoleMode()
        Log4swift.configure(fileLogConfig: .none)

        struct InnerType {
            init() {
                Log4swift[Self.self].info("Created instance of InnerType")
            }
        }
        Log4swift[Self.self].info("Before creating InnerType")
        InnerType()
        Log4swift[Self.self].info("Completed")
        Log4swift[Self.self].info("-----------")
    }

}
