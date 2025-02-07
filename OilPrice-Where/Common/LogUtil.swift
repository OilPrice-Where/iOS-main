//
//  LogUtil.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import OSLog

final class LogUtil {
    
    // MARK: - Log Event
    
    private enum LogEvent: String {
        case d = "[💬]" // debug
        case e = "[‼️]" // error
        case i = "[ℹ️]" // info
        case v = "[🔬]" // verbose
        case w = "[⚠️]" // warning
        case s = "[🔥]" // severe
    }
    
    // MARK: - Properties
    
    /// 시스템 식별자 (subsystem)은 보통 `Bundle identifier`를 할당
    private static let subsystem = Bundle.main.bundleIdentifier ?? "com.OilPriceWhere.wheregasoline"
    
    /// OSLog용 Logger 인스턴스
    private static let logger = Logger(subsystem: subsystem, category: "LogUtil")
    
    // MARK: - Public Methods
    
    /// error
    static func e(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        logger.error("\(buildMessage(object, event: .e, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    /// info
    static func i(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        logger.info("\(buildMessage(object, event: .i, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    /// debug
    static func d(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        logger.debug("\(buildMessage(object, event: .d, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    /// verbose
    static func v(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        // verbose의 경우 debug 레벨과 큰 차이가 없으므로 debug로 출력하거나,
        // 필요하다면 logger.trace(사전 정의) 등을 활용해도 무방함
        logger.debug("\(buildMessage(object, event: .v, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    /// warning
    static func w(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        logger.warning("\(buildMessage(object, event: .w, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    /// severe
    static func s(
        _ object: Any,
        filename: String = #file,
        line: Int = #line,
        column: Int = #column,
        funcName: String = #function
    ) {
        // 심각한 오류는 fault 레벨로 지정
        logger.fault("\(buildMessage(object, event: .s, filename: filename, line: line, column: column, funcName: funcName))")
    }
    
    // MARK: - Private Helpers
    
    /// 로그 메시지 포맷을 구성
    private static func buildMessage(
        _ object: Any,
        event: LogEvent,
        filename: String,
        line: Int,
        column: Int,
        funcName: String
    ) -> String {
        let file = sourceFileName(filePath: filename)
        return """
        \(String(describing: Date().toString())) \(event.rawValue)[\(file)]
        Line:\(line) 
        Column:\(column) 
        Function:\(funcName) ->
        \(object)
        """
    }
    
    /// 파일 경로에서 파일명만 추출
    private static func sourceFileName(filePath: String) -> String {
        let components = filePath.split(separator: "/")
        return components.last.map(String.init) ?? ""
    }
}
