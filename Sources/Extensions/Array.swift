//
//  Array.swift
//  P3Foundation
//
//  Created by Oscar Swanros on 6/15/16.
//  Copyright © 2016 Pacific3. All rights reserved.
//

public extension Array where Element: Equatable {
    mutating func remove(item: Element) {
        var index: Int?
        for (idx, it) in self.enumerated() {
            if item == it {
                index = idx
            }
        }
        
        if let index = index {
            self.remove(at: index)
        }
    }
}
