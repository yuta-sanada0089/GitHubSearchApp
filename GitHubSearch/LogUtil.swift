//
//  LogUtil.swift
//  GitHubSearch
//
//  Created by 真田雄太 on 2018/03/04.
//  Copyright © 2018年 yutaSanada. All rights reserved.
//

import Foundation

class LogUtil {
    static let SWIFT_FILENAME_SUFFIX = ".swift"
    
    static func traceFunc(className      file       : String                 = #file,
                          sourceLineNum  line       : Int                    = #line,
                          sourceFuncName funcName   : String                 = #function,
                          params         funcParams :Dictionary<String, Any> = Dictionary(),
                          message        msg        :String?                 = nil) {
        
        let prefix = getPrefix(file, line)
        NSLog(prefix + "\(funcName)")
        
        if (funcParams.isEmpty) {
            return
        }
        
        for (key, value) in funcParams {
            NSLog(prefix + "  >> \(key) : \(value)")
        }
        
        if let _ = msg {
            NSLog(prefix + " >> \(msg!)")
        }
    }
    
    static func debug(sourceFilePath file : String = #file,
                      sourceLineNum  line : Int    = #line,
                      _ message           : String) {
        let prefix = getPrefix(file, line)
        NSLog(prefix + "=> \(message)")
    }
    
    static func error(sourceFilePath file : String = #file,
                      sourceLineNum  line : Int    = #line,
                      _ error             : Error) {
        let prefix = getPrefix(file, line)
        NSLog(prefix + "=> \(error)")
    }
    
    static private func getPrefix(_ filePath : String,
                                  _ lineNum  : Int) -> String {
        let fileBaseName =
            URL(fileURLWithPath: filePath)
                .lastPathComponent
                .replacingOccurrences(of: SWIFT_FILENAME_SUFFIX, with: "")
        
        return "[\(fileBaseName) <line: \(String(format: "%3d", lineNum))>]"
    }
    
    static func calcSpace(_ target: String) -> String {
        var space = ""
        for _ in 0..<target.count {
            space += ""
        }
        return space
    }
}

protocol LogUtilProtocol {
    func traceFunc(sourceFunctName: String,
                   sourceLineNum : Int) -> Void
}

extension LogUtilProtocol {
    func traceFunc(sourceFunctName: String = #function,
                   sourceLineNum:  Int    = #line) {
        debugPrint("\(String(describing: type(of:self)))(\(sourceLineNum))::\(sourceFunctName)")
    }
}
