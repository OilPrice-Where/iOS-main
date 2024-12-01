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

extension OilPriceResultDTO {
    /// 유가 목록 데이터
    struct OilPriceListDTO: Decodable {
        let fuelPrices: [OilPriceDTO]?
        
        private enum CodingKeys: String, CodingKey {
            case fuelPrices = "OIL"
        }
    }
}

extension OilPriceResultDTO.OilPriceListDTO {
    /// 개별 유가 정보
    struct OilPriceDTO: Decodable {
        /// 거래 일자
        let tradeDate: String?
        /// 기름 코드
        let oilCode: String?
        /// 기름 타입
        let oilType: String?
        /// 가격
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
}


// MARK: - Mappings to Domain

extension OilPriceResultDTO {
    func toDomain() -> [OilPriceEntity] {
        return result?.toDomain() ?? []
    }
}

extension OilPriceResultDTO.OilPriceListDTO {
    func toDomain() -> [OilPriceEntity] {
        let prices = fuelPrices ?? []
        return prices.map {
            $0.toDomain()
        }
    }
}

extension OilPriceResultDTO.OilPriceListDTO.OilPriceDTO {
    func toDomain() -> OilPriceEntity {
        .init(
            tradeDate: tradeDate ?? "",
            oilCode: oilCode ?? "",
            oilName: mapOilCodeToProductName(),
            oilType: oilType ?? "",
            price: price ?? "0",
            diff: diff ?? ""
        )
    }
    
    /// 유가 코드를 제품명으로 매핑
    func mapOilCodeToProductName() -> String {
        switch oilCode {
        case "D047":
            return "dieselCost"
        case "B027":
            return "gasolineCost"
        case "K015":
            return "lpgCost"
        case "B034":
            return "premiumCost"
        default:
            return ""
        }
    }
}
