//
//  InformationGasStaion.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 17..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation

struct InformationOilStationResult: Decodable {
    let result: InformationGasStaions
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}

struct InformationGasStaions: Decodable {
    let allPriceList: [InformationGasStaion]
    
    private enum CodingKeys: String, CodingKey {
        case allPriceList = "OIL"
    }
}


struct InformationGasStaion: Decodable {
    let id: String! // 주유소 코드
    // 브랜드(SKE:SK에너지, GSC:GS칼텍스, HDO:현대오일뱅크, SOL:S-OIL, RTO:자영알뜰,
    //      RTX:고속도로알뜰, NHO:농협알뜰, ETC:자가상표, E1G: E1, SKG:SK가스
    let brand: String
    let name: String // 매장 이름
    let address: String // 주소
    let phoneNumber: String // 전화번호
    let qualityCertification: String //품질인증여부
    let repairShop: String // 카센터
    let convenienceStore: String // 편의점
    let carWash: String // 세차장
    
    private enum CodingKeys: String, CodingKey {
        case id = "UNI_ID"
        case brand = "POLL_DIV_CD"
        case name = "OS_NM"
        case address = "VAN_ADR"
        case phoneNumber = "TEL"
        case qualityCertification = "KPETRO_YN"
        case repairShop = "MAINT_YN"
        case convenienceStore = "CVS_YN"
        case carWash = "CAR_WASH_YN"
    }
}

/*
 
 {
 "RESULT": {
 "OIL": [
 {
 "UNI_ID": "A0028590",
 "POLL_DIV_CO": "SOL",
 "GPOLL_DIV_CO": "   ",
 "OS_NM": "도경셀프주유소",
 "VAN_ADR": "경남 창원시 의창구 동정동 224-1",
 "NEW_ADR": "경남 창원시 의창구 천주로56번길 1 (동정동)",
 "TEL": "055-296-2332",
 "SIGUNCD": "0902",
 "LPG_YN": "N",
 "MAINT_YN": "N",
 "CAR_WASH_YN": "Y",
 "KPETRO_YN": "N",
 "CVS_YN": "N",
 "GIS_X_COOR": 456280.9,
 "GIS_Y_COOR": 296648.7,
 "OIL_PRICE": [
 {
 "PRODCD": "B027",
 "PRICE": 1560,
 "TRADE_DT": "20180817",
 "TRADE_TM": "080158"
 },
 {
 "PRODCD": "D047",
 "PRICE": 1360,
 "TRADE_DT": "20180817",
 "TRADE_TM": "080503\r\n    \t "
 }
 ]
 }
 ]
 }
 }
 */
