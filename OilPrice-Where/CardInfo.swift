//
//  CardInfo.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/05.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation

struct CardInfo {
    var identifier: String = UUID().uuidString
    var name: String?
    var isLiter: Bool
    var saleValue: Double
    var applyBrands: [String]
}
