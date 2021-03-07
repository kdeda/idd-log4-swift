//
//  File.swift
//  
//
//  Created by Klajd Deda on 3/2/21.
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
