//
//  SettingUseCase.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol SettingUseCase {
    func load<T>(type: SettingType) throws -> T
    func save<T>(_ value: T, type: SettingType)
}


final class SettingUseCaseImpl: SettingUseCase {
    
    private let storage: SettingStorage
    
    init(storage: SettingStorage) {
        self.storage = storage
    }
    
    func load<T>(type: SettingType) throws -> T {
        guard let defaultValue = type.defaultValue as? T else {
            throw SettingError.invalidDefaultValue
        }
        
        return storage.fetchValue(
            defaultValue: defaultValue,
            forKey: type.key,
            fromStorageNamed: Constants.storageName
        )
    }
    
    func save<T>(_ value: T, type: SettingType) {
        storage.save(value, forKey: type.key, to: Constants.storageName)
    }
}

private extension SettingUseCaseImpl {
    enum Constants {
        static let storageName: String = "UserInfo"
    }
}
