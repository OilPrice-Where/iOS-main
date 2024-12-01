//
//  StationEndpoint.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Moya
import Foundation


enum StationAPI {
    /// 주변 주유소 정보 조회
    case nearbyGasStations(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String)
    /// 주유소 정보 조회
    case stationDetail(appKey: String, id: String)
    /// 유가 정보 조회 결과
    case oilPriceResult(appKey: String)
}


extension StationAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://www.opinet.co.kr/api")!
    }
    
    var path: String {
        switch self {
        case .nearbyGasStations:
            return "/aroundAll.do"
        case .stationDetail:
            return "/detailById.do"
        case .oilPriceResult:
            return "/avgAllPrice.do"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .nearbyGasStations:
            return .get
        case .stationDetail:
            return .get
        case .oilPriceResult:
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .nearbyGasStations(let x, let y, let radius, let prodcd, let sort, let appKey):
            let params: [String: Any] = [
                "code": appKey,
                "x": x,
                "y": y,
                "radius": radius,
                "sort": sort,
                "prodcd": prodcd,
                "out": "json"
            ]
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
            
        case .stationDetail(let appKey, let id):
            let params: [String: Any] = [
                "code": appKey,
                "id": id,
                "out": "json"
            ]
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
            
        case .oilPriceResult(let appKey):
            let params: [String: Any] = [
                "code": appKey,
                "out": "json"
            ]
            
            return .requestParameters(
                parameters: params,
                encoding: URLEncoding.queryString
            )
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json"
        ]
    }
}
