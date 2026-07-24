//
//  Array+Extensions.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 7/24/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation

/**
 Convenience for logging arrays
 ```
 # example 1:
 # given, columnTag: String and an array of objects that conform to .description
 Log4swift[Self.self].info("\(columnTag).items: '\(items.multilineDescription)'")

 # example 2:
 # given, columnTag: String and an array of objects that has an ivar called `filePath: String`
 Log4swift[Self.self].info("\(columnTag).selectedItem: '\(items.multilineDescription(\.filePath))'")
 ```
 */
extension Array {
    /**
     will return
     ```
     [
         row.description,
         row.description,
         row.description
     ]
     ```
     */
    public var multilineDescription: String {
        self.enumerated().reduce(into: "[") { partialResult, element in
            partialResult += "\n        "
            partialResult += "\(element.element)"
            if element.offset == self.count - 1 {
                partialResult += "\n]"
            }
            else {
                partialResult += ","
            }
        }
    }

    public func multilineDescription<Value>(
        _ keyPath: KeyPath<Element, Value>
    ) -> String where Value: CustomDebugStringConvertible
    {
        self.enumerated().reduce(into: "[") { partialResult, element in
            partialResult += "\n        "
            partialResult += "\(element.element[keyPath: keyPath])"
            if element.offset == self.count - 1 {
                partialResult += "\n]"
            }
            else {
                partialResult += ","
            }
        }
    }

}
