//
//  Extensions.swift
//  Log4swift
//
//  Created by Klajd Deda on 9/14/24.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
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
    private static var threadIDByIndex: [UInt64: Int] = [:]
    private static var lock = NSRecursiveLock()

    /**
     we can sneak upwards to 9999 thread count here
     if we get above that, we would mod it by 9999
     having accurate thread index ain't much of a big deal deal for this
     feel free to modify this to fit more digits, but the log lines will end up with mostly empty space
     */
    internal static var threadIdWith4Digits: String {
        let clampedDigits = 9999 // if you need, add one more 9 to add more digit

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

// MARK: - Date (Internal) -

extension Date {
    internal static var dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return dateFormatter
    }()

    internal static var timeStamp: String {
        dateFormatter.string(from: Date())
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
    internal static var isRunningInPreviewMode = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] != nil
}
