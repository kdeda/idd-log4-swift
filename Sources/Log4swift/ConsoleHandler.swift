//
//  ConsoleHandler.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
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
    /**
     by adding | as column separators we make the logs easier to visually and programatically parse.
     by trying to keep the basic columns of the same width it helps a bit more with visual feed back
     it appears as if you are reading  spread sheet

     threadIdWith3Digits will be at most 6 chars long, where 3 are the thread digits,
     without clamping, its column width would vary on a heavy threaded app, so we clamp it to a max of 3 digits for the thread number

     at this point the logs should be fairly formatted but we do more
     if you use bash you can use the amazing cut command to cut a line by tokens
     too bad it does not handle more than one char.

     copy paste a bunch of log lines and
     pbpaste | cut -d "|" -f 5
     The abouve command will discard the first 4 columns and display column 5 the last
     pbpaste | cut -d "|" -f 5 | grep filePath | sort
     */
    public func log(level: Logging.Logger.Level,
                    message: Logging.Logger.Message,
                    metadata: Logging.Logger.Metadata?,
                    source: String,
                    file: String,
                    function: String,
                    line: UInt) {
        let logLine = message.logLine(level: level, label: label, file: file, function: function)

        if ProcessInfo.isRunningInPreviewMode {
            print(logLine, terminator: "")
        } else {
            fputs(logLine, stdout)
        }
    }

    public init(label: String) {
        self.label = label
    }
}
