//
//  VisitedGasStation.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


struct VisitedGasStation: StationRepresentable {
    /// 주유소 Identifier
    var id: String
    /// 주유소 브랜드
    let brand: StationBrand
    /// 주유소 상호
    let name: String
    /// 주유한 유종 정보
    let fuelType: FuelType
    /// 방문 시 기록된 주유 가격
    let recordedPrice: Double
    /// 주유소 위치
    var coordinate: CoordinateSystem
    /// 방문 수
    var visitCount: Int = 1
    /// 방문 날짜
    let visitDate: Date
}
