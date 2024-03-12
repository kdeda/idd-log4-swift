////
////  FileLogging.swift
////  Log4swift
////
////  Created by Klajd Deda on 3/9/23.
////  Copyright (C) 1997-2024 id-design, inc. All rights reserved.
////
//
//import Foundation
//import Logging
//
//// Adapted from https://nshipster.com/textoutputstream/
//fileprivate struct FileHandlerOutputStream: TextOutputStream {
//    enum FileHandlerOutputStream: Error {
//        case couldNotCreateFile
//    }
//    
//    private let fileHandle: FileHandle
//    let encoding: String.Encoding
//    
//    init(localFile url: URL, encoding: String.Encoding = .utf8) throws {
//        if !FileManager.default.fileExists(atPath: url.path) {
//            guard FileManager.default.createFile(atPath: url.path, contents: nil, attributes: nil) else {
//                throw FileHandlerOutputStream.couldNotCreateFile
//            }
//        }
//        
//        let fileHandle = try FileHandle(forWritingTo: url)
//        fileHandle.seekToEndOfFile()
//        self.fileHandle = fileHandle
//        self.encoding = encoding
//    }
//    
//    mutating func write(_ string: String) {
//        if let data = string.data(using: encoding) {
//            fileHandle.write(data)
//        }
//    }
//}
//
//public struct FileLogger {
//    let stream: TextOutputStream
//    private var localFile: URL
//    
//    /**
//     TODO: kdeda
//     We could implement a file rotation here based on dates or file sizes etc
//     */
//    public init(to localFile: URL) throws {
//        self.stream = try FileHandlerOutputStream(localFile: localFile)
//        self.localFile = localFile
//    }
//    
//    public func handler(label: String) -> FileLogHandler {
//        return FileLogHandler(label: label, fileLogger: self)
//    }
//    
//    public static func logger(label: String, localFile url: URL) throws -> Logger {
//        let logging = try FileLogger(to: url)
//        return Logger(label: label, factory: logging.handler)
//    }
//    
//    /**
//     TODO: kdeda
//     We could implement a file rotation here based on dates or file sizes etc
//     */
//    public func write(_ message: String) {
//        var file = self.stream
//        file.write(message)
//    }
//}
