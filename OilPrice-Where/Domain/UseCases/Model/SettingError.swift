//
//  SettingError.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum SettingError: Error {
    case invalidDefaultValue
}


extension SettingError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidDefaultValue:
            return "기본 세팅 값이 없습니다. 기본 값을 세팅해주세요!"
        }
    }
}
