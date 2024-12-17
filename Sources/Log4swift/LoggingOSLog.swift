//
//  LoggingOSLog.swift
//  Log4swift
//
//  Created by Klajd Deda on 5/14/24.
//  Shamlessly lifted from https://github.com/chrisaljoudi/swift-log-oslog/blob/master/Sources/LoggingOSLog/LoggingOSLog.swift
//

#if os(iOS)

import Foundation
import Logging
import struct Logging.Logger
import os

public struct LoggingOSLog: LogHandler {
    public var logLevel: Logger.Level = .info
    public let label: String
    private let oslogger: OSLog

    public init(label: String) {
        self.label = label
        self.oslogger = OSLog(subsystem: label, category: "")
    }

    public init(label: String, log: OSLog) {
        self.label = label
        self.oslogger = log
    }

    /**
     Read the ConsoleHandler.log(level:) for more
     */
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    file: String,
                    function: String,
                    line: UInt) {
        var combinedPrettyMetadata = self.prettyMetadata
        if let metadataOverride = metadata, !metadataOverride.isEmpty {
            combinedPrettyMetadata = self.prettify(
                self.metadata.merging(metadataOverride) {
                    return $1
                }
            )
        }

        var formedMessage = message.description
        if combinedPrettyMetadata != nil {
            formedMessage += " -- " + combinedPrettyMetadata!
        }

#if DEBUG
        let infoAndThread = "<\(level.levelString) \(Thread.threadIdWith3Digits)>".padding(toLength: 10, withPad: " ", startingAt: 0)
        let message = {
            if self.label.isEmpty {
                "\(Date.timeStamp) | <\(ProcessInfo.processInfo.processIdentifier)> | \(infoAndThread) | \(message)\n"
            } else {
                "\(Date.timeStamp) | <\(ProcessInfo.processInfo.processIdentifier)> | \(infoAndThread) | \(self.label).\(function)  |  \(message)\n"
            }
        }()
#else
        let message = formedMessage
#endif
        if ProcessInfo.isRunningInPreviewMode {
            print(message, terminator: "")
        } else {
            os_log("%{public}@", log: self.oslogger, type: OSLogType.from(loggerLevel: level), message as NSString)
        }
    }

    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }

    /// Add, remove, or change the logging metadata.
    /// - parameters:
    ///    - metadataKey: the key for the metadata item.
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    private func prettify(_ metadata: Logger.Metadata) -> String? {
        if metadata.isEmpty {
            return nil
        }
        return metadata.map {
            "\($0)=\($1)"
        }.joined(separator: " ")
    }
}

extension OSLogType {
    static func from(loggerLevel: Logger.Level) -> Self {
        switch loggerLevel {
        case .trace:
            /// `OSLog` doesn't have `trace`, so use `debug`
            return .debug
        case .debug:
            return .debug
        case .info:
            // in my book, info should be treated same as .notice or .default
            // return .info
            return .default
        case .notice:
            // https://developer.apple.com/documentation/os/logging/generating_log_messages_from_your_code
            // According to the documentation, `default` is `notice`.
            return .default
        case .warning:
            /// `OSLog` doesn't have `warning`, so use `info`
            return .info
        case .error:
            return .error
        case .critical:
            return .fault
        }
    }
}

#endif
