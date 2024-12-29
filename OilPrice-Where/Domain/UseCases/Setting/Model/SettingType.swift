//
//  SettingType.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum SettingType {
    case fuelType
    case findBrands
    case navigationType
    case favorites
}

extension SettingType {
    var key: String {
        switch self {
        case .fuelType:
            return "OilType"
        case .findBrands:
            return "Brands"
        case .navigationType:
            return "NaviType"
        case .favorites:
            return "Favorites"
        }
    }
    
    var notificationName: Notification.Name {
        Notification.Name(rawValue: key)
    }
    
    var defaultValue: Any {
        switch self {
        case .fuelType:
            return ""
        case .findBrands:
            return [
                "SKE", "GSC", "HDO",
                "SOL", "RTO", "RTX",
                "NHO", "ETC", "E1G",
                "SKG"
            ]
        case .navigationType:
            return "kakao"
        case .favorites:
            return [String]()
        }
    }
}
