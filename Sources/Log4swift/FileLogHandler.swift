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
    
    //    public init(label: String, localFile url: URL) throws {
    //        self.label = label
    //        self.stream = try FileHandlerOutputStream(localFile: url)
    //    }
    
    public func log(level: Logger.Level,
                    message: Logger.Message,
                    metadata: Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let message = "\(Date.timeStamp) <\(ProcessInfo.processInfo.processIdentifier)> [\(level.levelString) \(Thread.threadId)] \(self.label).\(function)   \(message)\n"

        fileLogConfig.write(message)
        // fileLogger.write(message)
        // let prettyMetadata = metadata?.isEmpty ?? true
        //     ? self.prettyMetadata
        //     : self.prettify(self.metadata.merging(metadata!, uniquingKeysWith: { _, new in new }))
        // stream.write("\(self.timestamp()) \(level) \(self.label) :\(prettyMetadata.map { " \($0)" } ?? "") \(message)\n")
    }
    
    private func prettify(_ metadata: Logger.Metadata) -> String? {
        return !metadata.isEmpty ? metadata.map { "\($0)=\($1)" }.joined(separator: " ") : nil
    }
    
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()
    
    //    private func timestamp() -> String {
    //        var buffer = [Int8](repeating: 0, count: 255)
    //        var timestamp = time(nil)
    //        let localTime = localtime(&timestamp)
    //        
    //        strftime(&buffer, buffer.count, "%Y-%m-%dT%H:%M:%S%z", localTime)
    //        return buffer.withUnsafeBufferPointer {
    //            $0.withMemoryRebound(to: CChar.self) {
    //                String(cString: $0.baseAddress!)
    //            }
    //        }
    //    }
}
