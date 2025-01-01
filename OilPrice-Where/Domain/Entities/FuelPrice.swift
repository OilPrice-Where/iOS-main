//
//  FuelPrice.swift
//  OilPrice-Where
//
//  Created by wargi on 1/27/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


/// 주유소 유가 정보
struct FuelPrice: Hashable {
    let fuelType: FuelType
    let price: Int
}
