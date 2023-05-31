//
//  Logger.swift
//  Log4swift
//
//  Created by Klajd Deda on 3/9/23.
//  Copyright (C) 1997-2023 id-design, inc. All rights reserved.
//

import Foundation
import Logging

public extension Logger {
    var isDebug: Bool {
        self.logLevel == .debug
    }
}
