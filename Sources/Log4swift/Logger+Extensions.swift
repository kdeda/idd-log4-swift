//
//  Logger.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation
import Logging

extension Logging.Logger {
    public var isDebug: Bool {
        self.logLevel <= .debug
    }

    public var isTrace: Bool {
        self.logLevel <= .trace
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func info(
        function: String,
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        line: UInt = #line
    ) {
        self.log(level: .info, message(), metadata: nil, source: nil, file: file, function: function, line: line)
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func debug(
        function: String,
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        line: UInt = #line
    ) {
        self.log(level: .debug, message(), metadata: nil, source: nil, file: file, function: function, line: line)
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func error(
        function: String,
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        line: UInt = #line
    ) {
        self.log(level: .error, message(), metadata: nil, source: nil, file: file, function: function, line: line)
    }

    @inlinable
    public func dash(
        _ message: @autoclosure () -> Logger.Message,
        metadata: @autoclosure () -> Logger.Metadata? = nil,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        let stringMessage = message().description
        let dashMessage = {
            let maxCount = min(128, stringMessage.count)
            return Logger.Message.init(stringLiteral: String(repeating: "-", count: maxCount))
        }
        self.log(level: .info, dashMessage(), metadata: nil, source: nil, file: file, function: function, line: line)
    }

    @inlinable
    /**
     Convenience to log the function name, usually inside a client.
     */
    public func dash(
        function: String,
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        line: UInt = #line
    ) {
        self.dash(message(), metadata: nil, file: file, function: function, line: line)
    }

    @inlinable
    /**
     Convenience to log once per 60 seconds.
     Avoid frequent log messages of the exact same content.
     
     Whenever you hve messages that are too frequent replace them with this gem
     ```
     # before
     Log4swift[Self.self].info("path: '\(self.path)' isLocalMount: '\(isLocalMount)' isRemovable: '\(isRemovable)' isUnmountable: '\(isUnmountable)' isMobileBackups: '\(isMobileBackups)' isFuse: '\(isFuse)' description: '\(description ?? "unknown")' type: '\(type ?? "unknown")'")
     Log4swift[Self.self].error(".volumeUUIDStringKey and .volumeURLForRemountingKey failed, will default to the md5 hash for: '\(self.path)'")

     # after
     Log4swift[Self.self].infoOncePer("path: '\(self.path)' isLocalMount: '\(isLocalMount)' isRemovable: '\(isRemovable)' isUnmountable: '\(isUnmountable)' isMobileBackups: '\(isMobileBackups)' isFuse: '\(isFuse)' description: '\(description ?? "unknown")' type: '\(type ?? "unknown")'")
     Log4swift[Self.self].errorOncePer(".volumeUUIDStringKey and .volumeURLForRemountingKey failed, will default to the md5 hash for: '\(self.path)'")
     ```
     */
    public func infoOncePer(
        seconds: Int = 60, // in seconds
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Log4swiftCache[Self.self].shouldLog(message(), seconds) { logMessage in
            self.log(level: .info, logMessage, metadata: nil, source: nil, file: file, function: function, line: line)
        }
    }

    @inlinable
    /**
     Convenience to log once per 60 seconds.
     Avoid frequent log messages of the exact same content.
     */
    public func errorOncePer(
        seconds: Int = 60, // in seconds
        _ message: @autoclosure () -> Logger.Message,
        file: String = #fileID,
        function: String = #function,
        line: UInt = #line
    ) {
        Log4swiftCache[Self.self].shouldLog(message(), seconds) { logMessage in
            self.log(level: .error, logMessage, metadata: nil, source: nil, file: file, function: function, line: line)
        }
    }
}
