//
//  Extensions.swift
//  Log4swift
//
//  Created by Klajd Deda on 9/14/24.
//  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
//

import Foundation
import Logging

internal func currentThreadId() -> UInt64 {
    var threadId: UInt64 = 0

#if os(Linux)
    threadId = UInt64(pthread_self() as UInt)
#else
    if (pthread_threadid_np(nil, &threadId) != 0) {
        return threadId
    }
#endif

    return UInt64(threadId)
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
