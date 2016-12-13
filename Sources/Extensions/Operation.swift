//
//  Operation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension Operation {
    public func add(completion: @escaping (Void) -> Void) {
        if let existing = completionBlock {
            completionBlock = {
                existing()
                completion()
            }
        } else {
            completionBlock = completion
        }
    }
    
    public func add(dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
