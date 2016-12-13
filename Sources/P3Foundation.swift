//
//  P3Foundation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

// MARK: - Constants
public let kP3ApplicationHasAlreadyRunOnce = "net.Pacific3.kP3ApplicationHasAlreadyRunOnce"
public let kP3ErrorDomain = "net.Pacific3.ErrorDomainSpecification"



// MARK: - Public Functions
public func p3_documentsDirectory() -> NSString? {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first as NSString?
}

public func p3_executeOnMainThread(handler: (Void) -> Void) {
    if Thread.isMainThread {
        handler()
    } else {
        DispatchQueue.main.sync(execute: handler)
    }
}

public func p3_executeOnBackgroundThread(handler: @escaping (Void) -> Void) {
    DispatchQueue.global(qos: .background).async {
        handler()
    }
}

public func flatten<A>(x: A??) -> A? {
    if let y = x { return y }
    return nil
}

public func p3_executeOnMainThread<A>(x: A?, handler: ((A) -> Void)?) {
    if Thread.isMainThread {
        handler <*> x
    } else {
        DispatchQueue.main.async(execute: {
            handler <*> x
            }
        )
    }
}

public func p3_executeAfter(time: TimeInterval, handler: @escaping (Void) -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + time, execute: handler)
}

public func p3_executeOnFirstLaunch(handler: ((Void) -> Void)?) {
    let hasRunOnce = UserDefaults.p3_getBool(key: kP3ApplicationHasAlreadyRunOnce)
    
    guard let handler = handler, !hasRunOnce else {
        return
    }
    
    handler()
    UserDefaults.p3_setBool(key: kP3ApplicationHasAlreadyRunOnce, value: true)
}


// MARK: - Internal
func encode(_ o: Any) -> String? {
    guard let string = o as? NSString else {
        return nil
    }
    
    return string.removingPercentEncoding
}
