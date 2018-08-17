//
//  AverageCostData.swift
//  OilPrice-Where
//
//  Created by SolChan Ahn on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation

struct NationCostList: Decodable {
    let result: NationCost
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

struct NationCosts: Decodable {
    let nationCost: [NationCost]
    
    private enum CodingKeys: String, CodingKey {
        case nationCost = "OIL"
    }
}

struct NationCost: Decodable {
    let difference: String
    let price: Float
    let productCode: String
    let productName: String
    let tradeDate: Int
    
    private enum CodingKeys: String, CodingKey {
        case difference = "DIFF"
        case price = "PRICE"
        case productCode = "PRODCD"
        case productName = "PRODNM"
        case tradeDate = "TRADE_DT"
    }
}
