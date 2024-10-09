import XCTest
import Logging
@testable import Log4swift

final class Log4swiftTests: XCTestCase {
    static var allTests = [
        ("testLogFile", testLogFile)
    ]

    /**
     Test the log to file.
     Create a config with a file
     Log using it
     Assert that the message we logged is there
     */
    func testLogFile() throws {
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

            XCTAssertEqual(matched.count, logMessages.count)
        }
    }
}
