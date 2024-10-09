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

extension Thread {
    internal static var threadId: String {
        String(currentThreadId(), radix: 16, uppercase: false)
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
