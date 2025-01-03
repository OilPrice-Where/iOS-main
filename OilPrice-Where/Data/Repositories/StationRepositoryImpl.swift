//
//  StationRepositoryImpl.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import Moya


final class StationRepositoryImpl: StationRepository {
    private let provider = MoyaProvider<StationAPI>()
            
    func fetchNearbyGasStations(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String) {
        
    }
    
    func fetchStationDetails(id: String) async throws -> [GasStationDetail] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.stationDetail(id: id)) { result in
                switch result {
                case .success(let response):
                    do {
                        let gasStationInfoResultDTO = try response.map(GasStationInfoResultDTO.self)
                        continuation.resume(returning: gasStationInfoResultDTO.toDomain())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func fetchOilPriceResult() async throws -> [OilPrice] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.oilPriceResult) { result in
                switch result {
                case .success(let response):
                    do {
                        let oilPriceResultDTO = try response.map(OilPriceResultDTO.self)
                        continuation.resume(returning: oilPriceResultDTO.toDomain())
                    } catch {
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}
