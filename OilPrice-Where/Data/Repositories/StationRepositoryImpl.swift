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
    private let provider: MoyaProvider<StationAPI>
        
    func fetchNearbyGasStations(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String) {
        
    }
    
    func fetchStationDetail(appKey: String, id: String) {
        
    }
    
    func fetchOilPriceResult(appKey: String) async throws -> [OilPriceEntity] {
        try await withCheckedThrowingContinuation { continuation in
            provider.request(.oilPriceResult(appKey: appKey)) { result in
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
