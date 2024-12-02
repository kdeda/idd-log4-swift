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

extension Thread {
    private static var threadIDByIndex: [UInt64: Int] = [:]

    internal static var threadId: String {
        let threadID = currentThreadId()
        let index = {
            if let index = threadIDByIndex[threadID] {
                return index
            } else {
                let index = threadIDByIndex.count
                threadIDByIndex[threadID] = index
                return index
            }
        }()

        let rawString = (index == 0)
        ? "main"
        : "t(\(index))"

        return rawString.leftPadding(to: 6, withPad: " ")
    }
}

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
