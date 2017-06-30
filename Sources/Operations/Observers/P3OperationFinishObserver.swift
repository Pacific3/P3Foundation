//
//  P3OperationFinishObserver.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/29/17.
//  Copyright © 2017 Pacific3. All rights reserved.
//

public struct P3OperationFinishObserver<T: P3Operation>: P3OperationObserver {
    private let handler: (T, [NSError]) -> Void
    
    public init(handler: @escaping (T, [NSError]) -> Void) {
        self.handler = handler
    }
    
    public func operationDidStart(operation: Operation) { }
    public func operationDidCancel(operation: Operation) { }
    public func operation(operation: Operation, didProduceOperation newOperation: Operation) {}
    
    public func operationDidFinish(operation: Operation, errors: [NSError]) {
        guard let o = operation as? T else { return }
        
        handler(o, errors)
    }
}

