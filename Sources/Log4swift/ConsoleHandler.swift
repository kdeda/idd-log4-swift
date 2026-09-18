//
//  ConsoleHandler.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
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
    public  var logFunction: (@Sendable (_ identifier: String, _ event: Logging.LogEvent) -> Void)?

    public func log(event: LogEvent) {
        guard !ProcessInfo.isRunningInPreviewMode
        else {
            print(event.logLine(label: label), terminator: "")
            return
        }
        
        guard let logFunction = self.logFunction
        else {
            fputs(event.logLine(label: label), stdout)
            return
        }
        
        logFunction(label, event)
    }

    public init(label: String, logFunction: (@Sendable (_ identifier: String, _ event: Logging.LogEvent) -> Void)?) {
        self.label = label
        self.logFunction = logFunction
    }
}
