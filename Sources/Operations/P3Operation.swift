//
//  P3Operation.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/16/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

open class P3Operation: Operation {
    //MARK: - KVO
    @objc class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return ["state", "cancelledState"]
    }
    
    @objc class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return ["state"]
    }
    
    @objc class func keyPathsForValuesAffectingIsCancelled() -> Set<String> {
        return ["cancelledState"]
    }
    
    // MARK: - State management
    
    fileprivate enum State: Int, Comparable {
        case initialized
        case pending
        case evaluatingConditions
        case ready
        case executing
        case finishing
        case finished
        
        func canTransitionToState(target: State, operationIsCancelled cancelled: Bool) -> Bool {
            switch (self, target) {
            case (.initialized, .pending):
                return true
            case (.pending, .evaluatingConditions):
                return true
            case (.pending, .finishing) where cancelled:
                return true
            case (.pending, .ready) where cancelled:
                return true
            case (.evaluatingConditions, .ready):
                return true
            case (.ready, .executing):
                return true
            case (.ready, .finishing):
                return true
            case (.executing, .finishing):
                return true
            case (.finishing, .finished):
                return true
            default:
                return false
            }
        }
    }
    private var _state = State.initialized
    private let stateLock = NSLock()
    
    private var state: State {
        get {
            return stateLock.withCriticalScope {
                _state
            }
        }
        
        set(newState) {
            willChangeValue(forKey: "state")
            
            stateLock.withCriticalScope {
                guard _state != .finished else {
                    return
                }
                
                assert(_state.canTransitionToState(target: newState, operationIsCancelled: isCancelled), "invalid state transition.")
                _state = newState
            }
            
            didChangeValue(forKey: "state")
        }
    }
    
    // MARK: - Operation "readiness"
    private let readyLock = NSRecursiveLock()
    
    override open var isReady: Bool {
        var _ready = false
        
        readyLock.withCriticalScope {
            switch state {
                
            case .initialized:
                _ready = isCancelled
                
            case .pending:
                guard !isCancelled else {
                    state = .ready
                    _ready = true
                    return
                }
                
                if super.isReady {
                    evaluateConditions()
                }
                
                _ready = false
                
            case .ready:
                _ready = super.isReady || isCancelled
                
            default:
                _ready = false
            }
            
        }
        
        return _ready
    }
    
    private var _cancelled = false {
        willSet {
            willChangeValue(forKey: "cancelledState")
        }
        
        didSet {
            didChangeValue(forKey: "cancelledState")
            
            if _cancelled != oldValue && _cancelled == true {
                for observer in observers {
                    observer.operationDidCancel(operation: self)
                }
            }
        }
    }
    
    override open var isCancelled: Bool {
        return _cancelled
    }
    
    public var userInitiated: Bool {
        get {
            return qualityOfService == .userInitiated
        }
        
        set {
            assert(state < .executing, "Can't modify the state after user execution has begun.")
            
            qualityOfService = newValue ? .userInitiated : .default
        }
    }
    
    override open var isExecuting: Bool {
        return state == .executing
    }
    
    override open var isFinished: Bool {
        return state == .finished
    }
    
    
    private var _internalErrors = [NSError]()
    func cancelWithError(error: NSError? = nil) {
        if let error = error {
            _internalErrors.append(error)
        }
        
        cancel()
    }
    
    func didEnqueue() {
        state = .pending
    }
    
    
    // MARK: - Observers, conditions, dependencies
    private(set) var observers = [P3OperationObserver]()
    public func addObserver(observer: P3OperationObserver) {
        assert(state < .executing, "Can't modify observes after execution has begun.")
        
        observers.append(observer)
    }
    
    public func addFinishObserver<T>(observer: P3OperationFinishObserver<T>) {
        assert(state < .executing, "Can't modify observes after execution has begun.")
        
        observers.append(observer)
    }
    
    private(set) var conditions = [P3OperationCondition]()
    public func addCondition(condition: P3OperationCondition) {
        assert(state < .evaluatingConditions, "Can't add conditions once execution has begun.")
        
        conditions.append(condition)
    }
    
    override open func addDependency(_ operation: Operation) {
        assert(state < .executing, "Dependencies cannot be modified after execution has begun.")
        
        super.addDependency(operation)
    }
    
    func evaluateConditions() {
        assert(state == .pending && !isCancelled, "evaluating conditions out of order!")
        
        state = .evaluatingConditions
        
        guard conditions.count > 0 else {
            state = .ready
            return
        }
        
        OperationConditionEvaluator.evaluate(conditions: conditions, operation: self) { failures in
            if !failures.isEmpty {
                self.cancelWithErrors(errors: failures)
            }
            
            
            self.state = .ready
        }
    }
    
    
    // MARK: - Execution
    override final public func start() {
        super.start()
        
        if isCancelled {
            finish()
        }
    }
    
    override final public func main() {
        assert(state == .ready, "This operation must be performed by an operation queue.")
        
        if _internalErrors.isEmpty && !isCancelled {
            state = .executing
            
            for observer in observers {
                observer.operationDidStart(operation: self)
            }
            
            execute()
        } else {
            finish()
        }
    }
    
    open func execute() {
        fatalError("\(type(of: self)) must override `execute()`.")
    }
    
    public final func produceOperation(operation: Operation) {
        for observer in observers {
            observer.operation(operation: self, didProduceOperation: operation)
        }
    }
    
    override open func cancel() {
        if isFinished {
            return
        }
        
        _cancelled = true
        
        if state > .ready {
            finish()
        }
    }
    
    
    // MARK: - Finishing
    public final func finishWithError(error: NSError?) {
        if let error = error {
            finish(errors: [error])
        } else {
            finish()
        }
    }
    
    public func cancelWithErrors(errors: [NSError]) {
        _internalErrors += errors
        cancel()
    }
    
    private var hasFinished = false
    public func finish(errors: [NSError] = []) {
        if !hasFinished {
            hasFinished = true
            state = .finishing
            
            let combinedErrors = _internalErrors + errors
            finished(errors: combinedErrors)
            
            for observer in observers {
                observer.operationDidFinish(operation: self, errors: combinedErrors)
            }
            
            state = .finished
        }
    }
    
    func finished(errors: [NSError]) {
        // Optional
    }
    
    override final public func waitUntilFinished() {
        fatalError("Nope!")
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    }
}

// MARK: - Operators
private func <(lhs: P3Operation.State, rhs: P3Operation.State) -> Bool {
    return lhs.rawValue < rhs.rawValue
}

private func ==(lhs: P3Operation.State, rhs: P3Operation.State) -> Bool {
    return lhs.rawValue == rhs.rawValue
}
