//
//  Log4swiftCache.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 7/13/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation

/**
 Use it as a static variable to avoid printing the same darn log more than say once per minutes
 */
public final class Log4swiftCache: @unchecked Sendable {
    // we lock it outselves, using the lock
    internal static let shared = Log4swiftCache(identifier: "SHARED")

    private var identifier: String
    private var caches = [String: Log4swiftCache]()
    private var cachedMessage = [Log4SwiftCacheMessage.ID: Log4SwiftCacheMessage]()
    private var lock: UnfairLock = .init()
    private var logMessages: [Log4SwiftCacheMessage.ID: Log4SwiftCacheMessage] = [:]

    init(identifier: String) {
        self.identifier = identifier
    }

    public func shouldLog(
        _ message: @autoclosure () -> Logger.Message,
        _ intervalInSeconds: Int, // in seconds
        _ doLog: (_ logMessage: Logger.Message) -> Void
    )  {
        lock.lock()
        defer { lock.unlock() }

        let logMessage = message().description
        let md5 = logMessage.md5
        guard let lastMessage = logMessages[md5]
        else {
            logMessages[md5] = .init(date: .init(), logMessage: logMessage, md5: md5)
            doLog(Logger.Message(stringLiteral: logMessage))
            return
        }
        let elapsedTimeInSeconds = abs(Int(lastMessage.date.timeIntervalSinceNow))
        guard elapsedTimeInSeconds > intervalInSeconds
        else {
            return
        }
        logMessages[md5] = .init(date: .init(), logMessage: logMessage, md5: md5)
        doLog(Logger.Message(stringLiteral: logMessage))
    }

    private func getCache(_ identifier: String) -> Log4swiftCache {
        lock.lock()
        defer { lock.unlock() }

        if let rv = caches[identifier] {
            // we will get here for subsequent calls so the over head of this func is O(1)
            return rv
        }
        let rv = Log4swiftCache(identifier: identifier)
        caches[identifier] = rv
        return rv
    }

    /**
     Works the same as Log4swift
     Please define the names here with full name space.
     ie: 'IDDSwift.Process'

     Connvenience
     ```
     Log4swiftCache["IDDSwift.Process"].info("say something")
     Log4swiftCache["IDDSwift.Process"].error("error: '\(error)'")
     ```
     */
    static public subscript(identifier: String) -> Log4swiftCache {
        shared.getCache(identifier)
    }

    /**
     Connvenience
     ```
     Log4swiftCache[Self.self].info("say something")
     Log4swiftCache[Self.self].error("error: '\(error)'")
     ```
     */
    static public subscript<T>(_ classType: T.Type) -> Log4swiftCache {
        shared.getCache(ClassID.getClassID(classType))
    }
}
