//
//  Log4SwiftCacheMessage.swift
//  idd-log4-swift
//
//  Created by Klajd Deda on 7/13/26.
//  Copyright (C) 1997-2026 id-design, inc. All rights reserved.
//

import Foundation
import Crypto

internal struct Log4SwiftCacheMessage: Equatable, Identifiable {
    internal var id: String {
        md5
    }
    internal var date: Date
    internal var logMessage: String
    internal var md5: String

    internal init(date: Date, logMessage: String, md5: String) {
        self.date = date
        self.logMessage = logMessage
        self.md5 = md5
    }
}

internal extension Data {
    /**
     returns a unique fingerprint
     ie: 2E79D73C-EAB5-44E0-9DEC-75602872402E
     */
    var md5: String {
        let digest = Insecure.MD5.hash(data: self)
        var tokens = digest.map { String(format: "%02hx", $0) }

        if tokens.count == 16 {
            tokens.insert("-", at: 4)
            tokens.insert("-", at: 7)
            tokens.insert("-", at: 10)
            tokens.insert("-", at: 13)

            //  // not sure we need this ...
            //  if let uuid = UUID(uuidString: tokens.joined(separator: "").uppercased()) {
            //      return uuid.uuidString
            //  }
        }
        return tokens.joined(separator: "").uppercased()
    }
}

internal extension String {
    /**
     returns a unique fingerprint
     ie: 2E79D73C-EAB5-44E0-9DEC-75602872402E
     */
    var md5: String {
        return (data(using: .utf8) ?? Data()).md5
    }
}

