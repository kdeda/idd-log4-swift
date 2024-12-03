//
//  FileLogHandler.swift
//  Log4swift
//
//  Created by Klajd Deda on 5/10/23.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
//

import Foundation
import Logging

// Adapted from https://github.com/apple/swift-log.git

/// `FileLogHandler` is a simple implementation of `LogHandler` for directing
/// `Logger` output to a local file. Appends log output to this file, even across constructor calls.
public struct FileLogHandler: LogHandler {
    private let fileLogConfig: FileLogConfig
    private var label: String
    
    public var logLevel: Logger.Level = .info
    
    private var prettyMetadata: String?
    public var metadata = Logger.Metadata() {
        didSet {
            self.prettyMetadata = self.prettify(self.metadata)
        }
    }
    
    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }
    
    public init(label: String, fileLogConfig: FileLogConfig) {
        self.label = label
        self.fileLogConfig = fileLogConfig
    }

    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        // by adding | as column separators we make the logs easier to visually parse.
        // by trying to keep the basic columns of the same width it helps a bit more
        let infoAndThread = "<\(level.levelString) \(Thread.threadIdWith4Digits)>"
        // let infoAndThread = infoAndThread_.padding(toLength: 10, withPad: " ", startingAt: 0)
        let message = {
            if self.label.isEmpty {
                "\(Date.timeStamp) | <\(ProcessInfo.processInfo.processIdentifier)> | \(infoAndThread) | \(message)\n"
            } else {
                "\(Date.timeStamp) | <\(ProcessInfo.processInfo.processIdentifier)> | \(infoAndThread) | \(self.label).\(function)  |  \(message)\n"
            }
        }()

        if ProcessInfo.isRunningInPreviewMode {
            print(message, terminator: "")
        } else {
            fileLogConfig.write(message)
        }
    }
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()
}
