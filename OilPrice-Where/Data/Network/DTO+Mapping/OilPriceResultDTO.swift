//
//  OilPriceResultDTO.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


/// 유가 정보 조회 결과
struct OilPriceResultDTO: Decodable {
    let result: OilPriceListDTO?
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

/// 유가 목록 데이터
struct OilPriceListDTO: Decodable {
    let allPriceList: [OilPriceDTO]?
    
    private enum CodingKeys: String, CodingKey {
        case allPriceList = "OIL"
    }
}


/// 개별 유가 정보
struct OilPriceDTO: Decodable {
    /// 거래 일자
    let tradeDate: String?
    /// 기름 코드
    let oilCode: String?
    /// 기름 타입
    let oilType: String?
    // 가격
    let price: String?
    /// 저번주 평균가와 차이
    let diff: String?
    
    private enum CodingKeys: String, CodingKey {
        case tradeDate = "TRADE_DT"
        case oilCode = "PRODCD"
        case oilType = "PRODNM"
        case price = "PRICE"
        case diff = "DIFF"
    }
}
