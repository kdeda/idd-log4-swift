//
//  Extensions.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 9/14/24.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
//

import Foundation
import Logging
#if os(Windows)
import WinSDK
#endif

/**
 from swift-log/Tests/LoggingTests/TestLogger.swift
 */
internal func currentThreadId() -> UInt64 {
#if canImport(Darwin)
    return UInt64(pthread_mach_thread_np(pthread_self()))
#elseif os(Windows)
    return UInt64(GetCurrentThreadId())
#else
    return UInt64(pthread_self() as UInt)
#endif
}

// MARK: - String (Private) -

fileprivate extension String {
    func leftPadding(to length: Int, withPad character: Character) -> String {
        let stringLength = self.count

        if stringLength < length {
            return String(repeatElement(character, count: length - stringLength)) + self
        }
        return String(self.suffix(length))
    }

    // the character will be space
    //
    func leftPadding(to length: Int) -> String {
        return self.leftPadding(to: length, withPad: Character(" "))
    }
}

// MARK: - Thread (Internal) -

extension Thread {
    // we use the lock below
    nonisolated(unsafe) private static var threadIDByIndex: [UInt64: Int] = [:]
    private static let lock = NSRecursiveLock()

    /**
     we can sneak upwards to 999 thread count here
     if we get above that, we would mod it by 999
     having accurate thread index ain't much of a big deal deal for this
     feel free to modify this to fit more digits, but the log lines will end up with mostly empty space
     */
    internal static var threadIdWith3Digits: String {
        let clampedDigits = 999 // if you need any more digits just add one more 9 to this

        let threadID = currentThreadId()
        let index = {
            lock.withLock {
                if let index = threadIDByIndex[threadID] {
                    return index
                } else {
                    let index = threadIDByIndex.count
                    threadIDByIndex[threadID] = index
                    return index
                }
            }
        }()

        let rawString = (index == 0)
        ? "main"
        : "th." + "\(index  % clampedDigits)"

        return rawString
    }
}

// MARK: - Logging.Logger.Level (Internal) -

extension Logger.Level {
    internal var levelString: String {
        switch self {
        case .trace:    return "T"
        case .debug:    return "D"
        case .info:     return "I"
        case .notice:   return "N"
        case .warning:  return "W"
        case .error:    return "E"
        case .critical: return "C"
        }
    }
}

// MARK: - ProcessInfo (Internal) -

extension ProcessInfo {
    internal static let isRunningInPreviewMode = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
}
