//
//  ClassID.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 7/13/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation

/**
 Fast reusable helper to convert a `T.Type` to a String.
 Only for Log4swift internal usage.
 */
final class ClassID: @unchecked Sendable {
    // we lock it outselves, using the lock
    internal static let shared = ClassID()

    private var classIDs: UnfairLock = .init(initialState: [ObjectIdentifier: String]())

    /**
     Process /Users/kdeda/Developer/build/Debug/com.id-design.v8.whatsizehelper will return
     com_id_design_v8_whatsizehelper
     */
    private static let processName = {
        ProcessInfo.processInfo.processName
            .replacingOccurrences(of: ".", with: "_")
            .replacingOccurrences(of: "-", with: "_")
    }()


    /**
     Return the full name of the type the first chunk is the name space
     ie: 'Foundation.URL'
     ie: 'Swift.Array<WhatSize.SBItem>'

     To make long generic names more manageable such as this example `IDDPieChart.SlidingView<SwiftUI.ModifiedContent<SwiftUI.ModifiedContent<PieChart.MeasuringRootVolumeV2 ...`
     We will discard all built in SwiftUI types after the first `<` as to finish as `IDDPieChart.SlidingView<MeasuringRootVolumeV2>`
     */
    private func getClassID<T>(_ classType: T.Type) -> String {
        classIDs.withLock { classIDs in
            guard let identifier = classIDs[ObjectIdentifier(classType)]
            else {
                var identifier = String(reflecting: classType)
                var tokens = identifier.components(separatedBy: ".")

                if !tokens.isEmpty,
                   tokens[0] == Self.processName
                {
                    // tokens[0] = "APP"
                    tokens.remove(at: 0)
                    identifier = tokens.joined(separator: ".")
                }
                classIDs[ObjectIdentifier(classType)] = identifier
                return identifier
            }

            // we will get here for subsequent calls so the over head of this func is O(1)
            return identifier
        }
    }

    internal static func getClassID<T>(_ classType: T.Type) -> String {
        ClassID.shared.getClassID(classType)
    }
}
