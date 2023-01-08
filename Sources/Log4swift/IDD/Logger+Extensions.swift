//
//  Logger+Extensions.swift
//  Log4Swift
//
//  Created by Klajd Deda on 3/2/21.
//  Copyright (C) 2017-2023 id-design, inc. All rights reserved.
//

import Foundation

public extension Logger {
    var isDebug: Bool {
        return (self.thresholdLevel == LogLevel.Debug) || (self.thresholdLevel == LogLevel.Trace)
    }
    
    var isTrace: Bool {
        return (self.thresholdLevel == LogLevel.Trace)
    }
}
