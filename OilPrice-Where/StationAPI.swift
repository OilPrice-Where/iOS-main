//
//  StationAPI.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Moya


enum StationAPI {
    case stationList(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String)
    case stationDetail(appKey: String, id: String)
    case allPrices(appKey: String)
}

extension StationAPI: TargetType {
    var baseURL: URL {
        return URL(string: "http://www.opinet.co.kr/api")!
    }
    
    var path: String {
        switch self {
        case .stationList(_, _, _, _, _, _):
            return "/aroundAll.do"
        case .stationDetail(_, _):
            return "/detailById.do"
        case .allPrices(_):
            return "/avgAllPrice.do"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .stationList(x: _, y: _, radius: _, prodcd: _, sort: _, appKey: _):
            return .get
        case .stationDetail(_, _):
            return .get
        case .allPrices(appKey: _):
            return .get
        }
    }
    
    var task: Task {
        switch self {
        case .stationList(let x, let y, let radius, let prodcd, let sort, let appKey):
            let params: [String: Any] = [
                "code": appKey,
                "x": x,
                "y": y,
                "radius": radius,
                "sort": sort,
                "prodcd": prodcd,
                "out": "json"
            ]
            
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.queryString)
        case .stationDetail(let appKey, let id):
            let params: [String: Any] = [
                "code": appKey,
                "id": id,
                "out": "json"
            ]
            
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.queryString)
        case .allPrices(let appKey):
            let params: [String: Any] = [
                "code": appKey,
                "out": "json"
            ]
            
            return .requestParameters(parameters: params,
                                      encoding: URLEncoding.queryString)
        }
    }
    
    var headers: [String : String]? {
        return [
            "Content-type": "application/json"
        ]
    }
}
