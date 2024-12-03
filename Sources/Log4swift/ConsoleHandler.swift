//
//  ConsoleHandler.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
//

import Foundation
import Logging

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
    public func log(level: Logging.Logger.Level,
                    message: Logging.Logger.Message,
                    metadata: Logging.Logger.Metadata?,
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
            fputs(message, stdout)
        }
    }

    public init(label: String) {
        self.label = label
    }
}
