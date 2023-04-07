//
//  ConsoleHandler.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2023 id-design, inc. All rights reserved.
//

import Logging
import Foundation

internal func currentThreadId() -> UInt64 {
    var threadId: UInt64 = 0

#if os(Linux)
    threadId = UInt64(pthread_self() as UInt)
#else
    if (pthread_threadid_np(nil, &threadId) != 0) {
        return threadId
    }
#endif

    return UInt64(threadId)
}

public struct ConsoleHandler: LogHandler {
    public var metadata: Logging.Logger.Metadata = .init()
    public var logLevel: Logging.Logger.Level = .info

    public subscript(metadataKey metadataKey: String) -> Logger.Metadata.Value? {
        get {
            return self.metadata[metadataKey]
        }
        set {
            self.metadata[metadataKey] = newValue
        }
    }

    private var label: String
    private var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()
    public func log(level: Logging.Logger.Level,
                    message: Logging.Logger.Message,
                    metadata: Logging.Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let timeStamp = dateFormatter.string(from: Date())
        let levelString: String = {
            switch level {
            case .trace: return "T"
            case .debug: return "D"
            case .info: return "I"
            case .notice: return "N"
            case .warning: return "W"
            case .error: return "E"
            case .critical: return "C"
            }
        }()
        let threadId = String(currentThreadId(), radix: 16, uppercase: false)

        let message = "\(timeStamp) <\(ProcessInfo.processInfo.processIdentifier)> [\(levelString) \(threadId)] <\(self.label) \(function)>   \(message)\n"
        fputs(message, stdout)

        // self.log(level: level, message: message, metadata: metadata, file: file, function: function, line: line)
    }

    public init(label: String) {
        self.label = label
    }
}
