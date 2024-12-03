//
//  OilPriceEntity.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


struct OilPriceEntity: Hashable, Codable {
    /// 거래 일자
    let tradeDate: String
    /// 기름 코드
    let oilCode: String
    /// 유종 명
    let oilName: String
    /// 기름 타입
    let oilType: String
    /// 가격
    let oilPrice: String
    /// 저번주 평균가와 차이
    let diff: String
}
