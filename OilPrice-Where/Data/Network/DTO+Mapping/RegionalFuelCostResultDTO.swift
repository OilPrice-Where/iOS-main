//
//  RegionalFuelCostResultDTO.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


/// 지역별 연료 비용 결과 Response
struct RegionalFuelCostResultDTO: Decodable {
    let result: RegionalFuelCostListDTO?
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

/// 지역별 연료 비용 리스트
struct RegionalFuelCostListDTO: Decodable {
    let fuelCosts: [RegionalFuelCostDTO]?
    
    private enum CodingKeys: String, CodingKey {
        case fuelCosts = "OIL"
    }
}


/// 평균 연료 비용 세부 정보
struct RegionalFuelCostDTO: Decodable {
    /// 가격 차이
    let priceDifference: String?
    /// 연료 가격
    let price: Float?
    /// 연료 제품 코드
    let productCode: String?
    /// 연료 제품 이름
    let productName: String?
    /// 거래 일자
    let tradeDate: Int?
    
    private enum CodingKeys: String, CodingKey {
        case priceDifference = "DIFF"
        case price = "PRICE"
        case productCode = "PRODCD"
        case productName = "PRODNM"
        case tradeDate = "TRADE_DT"
    }
}
