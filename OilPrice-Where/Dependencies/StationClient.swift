//
//  StationClient.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import Moya
import CoreLocation

import ComposableArchitecture

enum StationError: Error {
    case notFoundLocation
    case notFoundAddress
}

struct StationClient {
    var requestStations: (_ isOrderByPrice: Bool) async throws -> ([GasStation])
    var requestAddress: () async throws -> (String)
}

extension StationClient: DependencyKey {
    static var liveValue: StationClient = StationClient(
        requestStations: { isOrderByPrice in
//            let location = await LocationManager.shared.updateLocation()
//            
            let testLocation = CLLocation(latitude: 37.47309518, longitude: 126.98189728)
            
            let stations = try await StationService.requestStations(
                withLocation: testLocation,
                isOrderByPrice: isOrderByPrice
            )
            
            return stations
        },
        requestAddress: {
//            guard let address = await LocationManager.shared.requestAddress() else {
//                throw StationError.notFoundAddress
//            }
            
            return ""
        }
    )
    
    
}

extension StationClient {
    
}

extension DependencyValues {
    var stationClient: StationClient {
        get { self[StationClient.self] }
        set { self[StationClient.self] = newValue }
    }
}
