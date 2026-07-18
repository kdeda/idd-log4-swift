//
//  UnfairLock.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 1/1/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(WinSDK)
import WinSDK
#else
import Foundation
#endif

/// A custom backport wrapper for `os_unfair_lock` compatible with macOS 11.0+
/// as well as Windows and Linux.
/// You can see private wrapper that demonstrates code that is windows specific.
public final class UnfairLock<State>: @unchecked Sendable {
#if canImport(Darwin)
    private var _lock = os_unfair_lock()
#elseif canImport(WinSDK)
    private var _lock = SRWLOCK()
#else
    private let _lock = NSLock()
#endif
    private var state: State

    public init(initialState: State) {
        self.state = initialState
#if canImport(WinSDK)
        InitializeSRWLock(&_lock)
#endif
    }

    func lock() {
#if canImport(Darwin)
        os_unfair_lock_lock(&_lock)
#elseif canImport(WinSDK)
        AcquireSRWLockExclusive(&_lock)
#else
        _lock.lock()
#endif
    }

    func unlock() {
#if canImport(Darwin)
        os_unfair_lock_unlock(&_lock)
#elseif canImport(WinSDK)
        ReleaseSRWLockExclusive(&_lock)
#else
        _lock.unlock()
#endif
    }

    /// Mutate or read the state protected by the lock safely
    public func withLock<R>(_ body: (inout State) -> R) -> R {
        lock()
        defer { unlock() }
        return body(&state)
    }
}
