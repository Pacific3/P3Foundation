//
//  NSLock.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension NSLock {
    func withCriticalScope<T>( block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}

public extension NSRecursiveLock {
    func withCriticalScope<T>( block: () -> T) -> T {
        lock()
        let value = block()
        unlock()
        return value
    }
}
