//
//  Service.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 25..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Alamofire

protocol ServiceType {
    static func gasStationList(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String, completion: @escaping (Result<OilList>) -> ())
}

struct ServiceList: ServiceType {
    static func gasStationList(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String, completion: @escaping (Result<OilList>) -> ()) {
        Alamofire
            .request(API.aroundAll(x: x, y: y, radius: radius, prodcd: prodcd, sort: sort, appKey: appKey).urlString)
            .validate()
            .responseData(completionHandler: { (response) in
                switch response.result {
                case .success(let value):
                    do {
                        let restaurantData = try value.decode(OilList.self)
                        completion(.success(restaurantData))
                    } catch {
                        completion(.error(error))
                    }
                case .failure(let error):
                    completion(.error(error))
                }
            })
    }
}
