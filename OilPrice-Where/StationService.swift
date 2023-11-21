//
//  StationService.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import Foundation
import Moya
import CoreLocation
import NMapsMap


final class StationService: NSObject {
    enum NetworkError: Error {
        case location // => Location
        case requestStation // => Network
        case decoding // => Response
    }
    
    static private let staionProvider = MoyaProvider<StationAPI>()
    
    static func requestStations(withLocation location: CLLocation?,
                                isOrderByPrice: Bool) async throws -> [GasStation] {
        return try await withCheckedThrowingContinuation { continuation in
            guard let location else {
                continuation.resume(throwing: NetworkError.location)
                return
            }
            
            let oilSubject = DefaultData.shared.oilSubject.value
            let brands = DefaultData.shared.brandsSubject.value
            
            let coordinate = location.coordinate
            let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
            let tm = NMGTm128(from: latLng)
            
            staionProvider.request(.stationList(x: tm.x,
                                                y: tm.y,
                                                radius: 5000,
                                                prodcd: oilSubject,
                                                sort: isOrderByPrice ? 1 : 0,
                                                appKey: Preferences.getAppKey())) { result in
                switch result {
                case .success(let response):
                    guard let list = try? response.map(OilList.self) else {
                        continuation.resume(throwing: NetworkError.decoding)
                        return
                    }
                    
                    var target = list.result.gasStations.map { station -> GasStation in
                        let stationLatLng = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
                        let stationLocation = CLLocation(latitude: stationLatLng.lat, longitude: stationLatLng.lng)
                        let distanceValue = stationLocation.distance(from: location)
                        
                        return GasStation.init(id: station.id, brand: station.brand, name: station.name, price: station.price, distance: distanceValue, katecX: station.katecX, katecY: station.katecY)
                    }
                    
                    if brands.count != 10 {
                        target = target.filter { brands.contains($0.brand) }
                    }
                    
                    continuation.resume(returning: target)
                case .failure(let error):
                    LogUtil.e(error.localizedDescription)
                    continuation.resume(throwing: NetworkError.requestStation)
                }
            }
        }
    }
}
