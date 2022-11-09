//
//  StationAttributes.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/11/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import ActivityKit

struct FindStation: Codable, Hashable {
    let id: String?
    let name: String? // 매장 이름
    let brand: String?
    let oil: String?
    let price: Int?
    let lat: Double?
    let lng: Double?
    var distance: String?
}

struct StationAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var station: FindStation?
    }
}
