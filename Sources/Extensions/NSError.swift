//
//  NSError.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension NSError {
    public convenience init(error: P3ErrorSpecification<Int, String, String>) {
        self.init(
            domain: error.domain,
            code: error.code,
            userInfo: [NSLocalizedDescriptionKey:error.errorDescription]
        )
    }
    
    public convenience init(error: P3ErrorSpecification<Int, String, String>, userInfo: [String:Any]) {
        self.init(
            domain: error.domain,
            code: error.code,
            userInfo: userInfo
        )
    }
}

