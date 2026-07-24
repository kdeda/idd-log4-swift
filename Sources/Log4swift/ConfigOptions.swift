//
//  ConfigOptions.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 1/9/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation
import Logging

/**
 Helper to configure loggin
 Usually from command line, ie: `UserDefaults.standard.volatileDomain(forName: "NSArgumentDomain")`
 */
public struct ConfigOptions: OptionSet, Sendable {
    public let rawValue: Int

    // display the time column as `yyyy-MM-dd HH:mm:ss.SSS`
    static let defaultTimeStamp = Self(rawValue: 1 << 0)

    // display the time column as `HH:mm:ss.SSS`
    static let compactTimeStamp = Self(rawValue: 1 << 1)

    // do not display the processid column
    // default process pid number as `<16254> or <19876>`
    static let processID = Self(rawValue: 1 << 2)

    // do not display the thread column
    // default display the thread column as `<I main> or <I t14>, where t14 is the thread number, up to 999`
    static let threadColumn = Self(rawValue: 1 << 3)

    // displays the file name and line count as `Log4swift/Log4swift.swift:114`
    // by default is on, it can be removed via the
    static let fileName = Self(rawValue: 1 << 4)

    // displays the name of the Swift.Type as `IDDList.IDDList<IDDFolderScan.NodeEntry> or Swift.String or Swift.AsyncStream<Swift.Array<IDDFolderScan.NodeEntry>>`
    // by default is off, it can be added via the -Log4swift.hideSwiftTypeName false
    static let swiftTypeName = Self(rawValue: 1 << 5)

    // display the name of a function as `.categorize or ._handleEvent(_:) etc`
    // by default is on and can't be removed
    static let functionName = Self(rawValue: 1 << 6)

    // display the argument config such as `Using 'I', info level for: 'Log4swiftTests.Log4swiftTests'`
    static let argumentHelp = Self(rawValue: 1 << 7)

    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /**
     Will set the following as arguments to avoid them being persisted
     -Log4swift.compactTimeStamp true
     -Log4swift.hideProcessID true
     -Log4swift.hideFileName true
     -Log4swift.hideSwiftTypeName true
     */
    static public func configureCompactSettings() {
        var domain = UserDefaults.standard.volatileDomain(forName: "NSArgumentDomain")

        domain["Log4swift.compactTimeStamp"] = "true"
        domain["Log4swift.hideProcessID"] = "true"
        domain["Log4swift.hideFileName"] = "true"
        domain["Log4swift.hideSwiftTypeName"] = "true"

        UserDefaults.standard.setVolatileDomain(domain, forName: "NSArgumentDomain")
    }

    /**
     Good for console level logging, very compact
     Will set the following as arguments to avoid them being persisted
     -Log4swift.compactTimeStamp true
     -Log4swift.hideProcessID true
     -Log4swift.hideThreadColumn true
     -Log4swift.hideFileName true
     -Log4swift.hideSwiftTypeName true
     -Log4swift.hideFunctionName true
     -Log4swift.hideArgumentHelp true
     */
    static public func configureConsoleMode() {
        var domain = UserDefaults.standard.volatileDomain(forName: "NSArgumentDomain")

        domain["Log4swift.compactTimeStamp"] = "true"
        domain["Log4swift.hideProcessID"] = "true"
        domain["Log4swift.hideThreadColumn"] = "true"
        domain["Log4swift.hideFileName"] = "true"
        domain["Log4swift.hideSwiftTypeName"] = "true"
        domain["Log4swift.hideFunctionName"] = "true"
        domain["Log4swift.hideArgumentHelp"] = "true"

        UserDefaults.standard.setVolatileDomain(domain, forName: "NSArgumentDomain")
    }

    /**
     Return default set with [.defaultTimeStamp, .processID, .threadColumn, .fileName, .swiftTypeName, .functionName]
     */
    public static let defaultOptions: Self = {
        let options: Self = [
            .defaultTimeStamp,
            .processID,
            .threadColumn,
            .fileName,
            // .swiftTypeName,
            .functionName,
            .argumentHelp
        ]
        return options
    }()

    /**
     It will start with the .defaultOptions
     and will remove options as you configure on the defaults
     */
    public static let optionsFromUserDefaults: Self = {
        var domain = UserDefaults.standard.volatileDomain(forName: "NSArgumentDomain")
        var options: Self = .defaultOptions

        if UserDefaults.standard.bool(forKey: "Log4swift.compactTimeStamp") {
            options.remove(.defaultTimeStamp)
            options.insert(.compactTimeStamp)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideProcessID") {
            options.remove(.processID)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideThreadColumn") {
            options.remove(.threadColumn)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideFileName") {
            options.remove(.fileName)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideSwiftTypeName") {
            options.remove(.swiftTypeName)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideFunctionName") {
            options.remove(.functionName)
        }

        if UserDefaults.standard.bool(forKey: "Log4swift.hideArgumentHelp") {
            options.remove(.argumentHelp)
        }

        return options
    }()
}

extension ConfigOptions: CustomStringConvertible {
    public var description: String {
        var tokens: [String] = []

        if contains(.compactTimeStamp) {
            tokens.append("TIME_STAMP.compactTimeStamp")
        } else {
            tokens.append("TIME_STAMP.defaultTimeStamp")
        }
        if contains(.processID) {
            tokens.append("PROCESS_ID.processID")
        }
        if contains(.threadColumn) {
            tokens.append("THREAD_ID.threadColumn")
        }
        if contains(.fileName) {
            tokens.append("FILE_NAME.fileName")
        }
        if contains(.swiftTypeName) {
            tokens.append("SWIFT_TYPE.swiftTypeName")
        }
        if contains(.functionName) {
            tokens.append("FUNCTION_NAME.functionName")
        }
        if contains(.argumentHelp) {
            tokens.append(".argumentHelp")
        }

        return tokens.isEmpty ? "No options selected" : tokens.joined(separator: ", ")
    }
}
