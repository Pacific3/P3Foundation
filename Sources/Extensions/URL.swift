//
//  URL.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension URL {
    public func p3_append(params: [String:String])-> URL? {
        return URL(string: "\(self.absoluteString ?? "")?\(params.p3_URLEncodedString())")
    }
}
