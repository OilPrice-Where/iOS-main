//
//  FindOilType.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation



enum FuelType: String, CaseIterable {
    /// 휘발유
    case gasoline = "B027"
    /// 고급휘발유
    case premiumGasoline = "B034"
    /// 경유
    case diesel = "D047"
    /// LPG
    case lpg = "K015"
    
    
    init(code: String) {
        self = FuelType(rawValue: code.uppercased()) ?? .gasoline
    }
    
    init(displayName name: String) {
        self = FuelType.allCases.first(where: { $0.displayName == name }) ?? .gasoline
    }
}

extension FuelType {
    /// Fuel code
    var code: String {
        self.rawValue
    }
    
    /// Fuel name
    var displayName: String {
        switch self {
        case .gasoline:
            return "휘발유"
        case .premiumGasoline:
            return "고급휘발유"
        case .diesel:
            return "경유"
        case .lpg:
            return "LPG"
        }
    }
}
