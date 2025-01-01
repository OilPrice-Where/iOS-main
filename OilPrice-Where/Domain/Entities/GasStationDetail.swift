//
//  GasStationDetail.swift
//  OilPrice-Where
//
//  Created by wargi on 1/27/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


struct GasStationDetail: StationRepresentable {
    /// 주유소 코드
    let id: String
    /// 주유소 브랜드
    let brand: StationBrand
    /// 매장 이름
    let name: String
    /// 주유소 주소
    let address: String
    /// 주유소 전화번호
    let phoneNumber: String
    /// 품질 인증 여부
    let isQualityCertified: Bool
    /// 카센터 여부
    let hasRepairShop: Bool
    /// 편의점 여부
    let hasConvenienceStore: Bool
    /// 세차장 여부
    let hasCarWash: Bool
    /// 유가 정보 리스트
    let prices: [FuelPrice]
    /// 주유소 위치
    var coordinate: CoordinateSystem
}
