//
//  LogUtil.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation

final class LogUtil {
    private enum LogEvent: String {
        case d = "[💬]" // debug
        case e = "[‼️]" // error
        case i = "[ℹ️]" // info
        case v = "[🔬]" // verbose
        case w = "[⚠️]" // warning
        case s = "[🔥]" // severe
    }
    
    // error
    static func e( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.e.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    // info
    static func i( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.i.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    // debug
    static func d( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.d.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    // verbose
    static func v( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.v.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    // warning
    static func w( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.w.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    // severe
    public class func s( _ object: Any,// 1
        filename: String = #file, // 2
        line: Int = #line, // 3
        column: Int = #column, // 4
        funcName: String = #function) {
        print("""
            ------------------------------------------------------------------------------------
            \(String(describing: Date().toString)) \(LogEvent.s.rawValue)[\(sourceFileName(filePath: filename))]
            Line:\(line)
            Column:\(column)
            Function:\(funcName) ->
            \(object)
            ------------------------------------------------------------------------------------
            """)
    }
    
    private static func print(_ object: Any) {
        #if DEBUG
        Swift.print(object)
        #endif
    }
    
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.components(separatedBy: "/")
        return components.isEmpty ? "" : components.last ?? ""
    }
}
