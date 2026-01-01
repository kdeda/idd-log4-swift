//
//  UnfairLock.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 1/1/26.
//  Copyright (C) 1997-2025 id-design, inc. All rights reserved.
//

#if canImport(Darwin)
import Darwin
#elseif canImport(WinSDK)
import WinSDK
#else
import Foundation
#endif

/**
 This is not recursive.
 A private wrapper to demonstrate code that is windows specific.
 */
internal final class UnfairLock {
    #if canImport(Darwin)
    private var _lock = os_unfair_lock()
    #elseif canImport(WinSDK)
    private var _lock = SRWLOCK()
    #else
    private let _lock = NSLock()
    #endif
    
    init() {
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
    
    func withLock<T>(_ body: () throws -> T) rethrows -> T {
        lock()
        defer { unlock() }
        return try body()
    }
}
