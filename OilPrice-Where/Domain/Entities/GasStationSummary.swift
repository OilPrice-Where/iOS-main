//
//  GasStationSummary.swift
//  OilPrice-Where
//
//  Created by wargi on 1/27/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


struct GasStationSummary: StationRepresentable {
    /// 주유소 코드
    let stationID: String
    /// 주유소 브랜드
    let brand: StationBrand
    /// 매장 이름
    let name: String
    /// 가격
    let price: Int
    /// 기준 위치로부터의 거리 (단위 : m)
    var distance: Double
    /// 주유소 위치
    var coordinate: CoordinateSystem
}
