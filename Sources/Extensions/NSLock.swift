//
//  NSLock.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension NSLock {
    public func withCriticalScope<T>( block: (Void) -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

public extension NSRecursiveLock {
    public func withCriticalScope<T>( block: (Void) -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
