//
//  Log4swiftConfig.swift
//  Tides
//
//  Created by Klajd Deda on 4/20/17.
//  Copyright © 2017 Klajd Deda. All rights reserved.
//

import Foundation

public class Log4swiftConfig: NSObject {
    public static func configureLogs(defaultLogFile aDefaultLogFile: String?, lock theLock: String) {
        let processIdentifier = ProcessInfo.processInfo.processIdentifier
        let sharedFactory = LoggerFactory.sharedInstance
        let defaultFormatter = try! PatternFormatter(identifier: "default formatter", pattern: "%D <" + processIdentifier.description + "> [%l %t] <%n %M> %m")
        let standardLog = UserDefaults.standard.bool(forKey: "standardLog")
        
        if aDefaultLogFile == nil || standardLog {
            // log on the console
            //
            let stdOutAppender = StdOutAppender("stdOutAppender")

            stdOutAppender.formatter = defaultFormatter
            sharedFactory.rootLogger.appenders = [stdOutAppender]
            sharedFactory.rootLogger.thresholdLevel = LogLevel.Info
        } else {
            // log on the log file
            //
            let logFilePath = NSString.init(string: aDefaultLogFile!)
            let fileAppender = FileAppender(identifier: "fileAppender", filePath: logFilePath as String)
            
            /*
             We need to do some cooking in the FileAppender.swift to add some thread locking
             Since IDDLog uses this same handler
             
             public var iddLock = "iddLock"
             
             // replace self.fileHandler?.write(dataToLog)
             // with
             //
             objc_sync_enter(iddLock)
             self.fileHandler?.write(dataToLog)
             objc_sync_exit(iddLock)
             */
            
            fileAppender.formatter = defaultFormatter
            // fileAppender.thresholdLevel = LogLevel.Error
            sharedFactory.rootLogger.appenders = [fileAppender]
            sharedFactory.rootLogger.thresholdLevel = LogLevel.Info
        }
    }
}

public class IDDLog4swift: NSObject {
    static public func getLogger(_ identifier: String) -> Logger {
        let rv = Logger.getLogger(identifier)
        let level: String = {
            if let rv = UserDefaults.standard.string(forKey: identifier) {
                return rv
            }
            // Foobar.Foo class names
            //
            var derivedShortClassName = "UnknownClassName"
            let tokens = identifier.components(separatedBy: ".")

            if tokens.count > 1 {
                // Foobar.Foo type class names
                //
                derivedShortClassName = tokens[tokens.count - 1]
                return UserDefaults.standard.string(forKey: derivedShortClassName) ?? ""
            } else {
                // Foobar<Foo> type class names
                //
                let tokens = identifier.components(separatedBy: "<")
                
                if tokens.count > 1 {
                    derivedShortClassName = tokens[0]
                    return UserDefaults.standard.string(forKey: derivedShortClassName) ?? ""
                }
            }
            return ""
        }()
        
        if level == "D" {
            rv.thresholdLevel = LogLevel.Debug
        } else if level == "T" {
            rv.thresholdLevel = LogLevel.Trace
        }
        return rv
    }
    
    static public func getLogger(_ value: Any) -> Logger {
        return IDDLog4swift.getLogger(String(describing: type(of: value)))
    }
    
    static public subscript(identifier: String) -> Logger {
        getLogger(identifier)
    }
    
    static public subscript<T>(type: T.Type) -> Logger {
        return getLogger(String(reflecting: type))
    }
}
