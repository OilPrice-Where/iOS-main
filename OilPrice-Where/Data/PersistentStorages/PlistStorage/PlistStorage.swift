//
//  PlistStorage.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol SettingStorage {
    /// 지정된 저장소에서 세팅 값 반환
    func fetchValue<T>(defaultValue: T, forKey key: String, fromStorageNamed name: String) -> T
    /// 지정된 저장소에 값을 저장
    func save<T>(_ type: T, forKey key: String, to name: String, completion: () -> Void)
}


final class PlistSettingStorage: SettingStorage {
    func fetchValue<T>(defaultValue: T, forKey key: String, fromStorageNamed name: String = "UserInfo") -> T {
        if let value = SwiftyPlistManager.shared.fetchValue(for: key, fromPlistWithName: name) as? T {
            return value
        } else {
            SwiftyPlistManager.shared.addNew(
                defaultValue,
                key: key,
                toPlistWithName: name,
                completion: { _ in }
            )
            return defaultValue
        }
    }
    
    func save<T>(_ type: T, forKey key: String, to name: String = "UserInfo", completion: () -> Void) {
        SwiftyPlistManager.shared.save(type, forKey: key, toPlistWithName: name) {
            if let error = $0 {
                LogUtil.e(error.localizedDescription)
            }
            completion()
        }
    }
}
