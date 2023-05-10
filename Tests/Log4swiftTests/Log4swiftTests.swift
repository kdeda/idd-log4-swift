import XCTest
import Logging
@testable import Log4swift

final class Log4swiftTests: XCTestCase {
    static var allTests = [
        ("testExample", testExample),
    ]

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        // XCTAssertEqual(Log4swift().text, "Hello, World!")
    }

    /**
     Test the log to file.
     */
    func testLogFile() {
        let home: URL = {
            let uid = getuid()
            guard uid != 0
            else { return URL.init(fileURLWithPath: "/") }

            return URL.init(fileURLWithPath: NSHomeDirectory())
        }()
        let appName = "test"
        let fileURL = home.appendingPathComponent("Library/Logs").appendingPathComponent(appName).appendingPathExtension("log")

        if !FileManager.default.fileExists(atPath: fileURL.path) {
            try? "".write(to: fileURL, atomically: true, encoding: .utf8)
        }

        if let handle = try? FileHandle(forReadingFrom: fileURL) {
            _ = try? handle.seekToEnd()
            let logMessages = ["Hello message1", "We are going to assert this"]
            let fileLogger = try? FileLogger(to: fileURL)

            // configure it to use file
            LoggingSystem.bootstrap { label in
                FileLogHandler(label: label, fileLogger: fileLogger!)
            }
            // log a message
            logMessages.forEach { logMessage in
                Log4swift[Self.self].info("\(logMessage)")
            }

            // assert
            let readMessages_ = String(data: handle.availableData, encoding: .utf8) ?? ""
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
