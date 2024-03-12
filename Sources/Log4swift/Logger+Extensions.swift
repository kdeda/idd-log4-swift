//
//  Logger.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
//

import Foundation
import Logging

extension Logging.Logger {
    public var isDebug: Bool {
        self.logLevel == .debug
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func info(function: String, _ message: @autoclosure () -> Logger.Message) {
        self.log(level: .info, message(), metadata: nil, source: nil, file: #file, function: function, line: #line)
    }
    
    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func debug(function: String, _ message: @autoclosure () -> Logger.Message) {
        self.log(level: .debug, message(), metadata: nil, source: nil, file: #file, function: function, line: #line)
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func error(function: String, _ message: @autoclosure () -> Logger.Message) {
        self.log(level: .error, message(), metadata: nil, source: nil, file: #file, function: function, line: #line)
    }
}
