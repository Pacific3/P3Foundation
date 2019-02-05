//
//  Operation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension Operation {
    func add(completion: @escaping () -> Void) {
        if let existing = completionBlock {
            completionBlock = {
                existing()
                completion()
            }
        } else {
            completionBlock = completion
        }
    }
    
    func add(dependencies: [Operation]) {
        for dependency in dependencies {
            addDependency(dependency)
        }
    }
}
