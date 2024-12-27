//
//  FileLogHandler.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 5/10/23.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
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

    /**
     Read the ConsoleHandler.log(level:) for more
     */
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let logLine = message.logLine(level: level, label: label, file: file, function: function)

        if ProcessInfo.isRunningInPreviewMode {
            print(logLine, terminator: "")
        } else {
            fileLogConfig.write(logLine)
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
