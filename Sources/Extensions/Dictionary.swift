//
//  Dictionary.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
    public func p3_number(key: Key) -> NSNumber? {
        return self[key] >>>= { $0 as? NSNumber }
    }
    
    public func p3_int(key: Key) -> Int? {
        return self.p3_number(key: key).map { $0.intValue }
    }
    
    public func p3_float(key: Key) -> Float? {
        return self.p3_number(key: key).map { $0.floatValue }
    }
    
    public func p3_double(key: Key) -> Double? {
        return self.p3_number(key: key).map { $0.doubleValue }
    }
    
    public func p3_string(key: Key) -> String? {
        return self[key] >>>= { $0 as? String }
    }
    
    public func p3_bool(key: Key) -> Bool? {
        return self.p3_number(key: key).map { $0.boolValue }
    }
}

public extension Dictionary {
    static func p3_fromURL(query: String) -> [String:String] {
        var dict: [String:String] = [:]
        let pairs = query.components(separatedBy: "&")
        for pair in pairs {
            let sub = pair.components(separatedBy: "=")
            dict[sub[0]] = sub[1]
        }
        
        return dict
    }
}

extension Dictionary where Key: ExpressibleByStringLiteral, Value: ExpressibleByStringLiteral {
    public func p3_URLEncodedString() -> String {
        var pairs = [String]()
        for element in self {
            if
                let key = encode(element.0 as AnyObject),
                let value = encode(element.1 as AnyObject), (!value.isEmpty && !key.isEmpty) {
                pairs.append([key, value].joined(separator: "="))
            } else {
                continue
            }
        }
        
        guard !pairs.isEmpty else {
            return ""
        }
        
        return pairs.joined(separator: "&")
    }
}
