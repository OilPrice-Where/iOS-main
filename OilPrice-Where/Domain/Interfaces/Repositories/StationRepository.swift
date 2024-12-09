//
//  StationRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol StationRepository {
    /// 주변 주유소 정보를 조회합니다.
    func fetchNearbyGasStations(x: Double, y: Double, radius: Int, prodcd: String, sort: Int, appKey: String)
    /// 특정 주유소의 상세 정보를 조회합니다.
    func fetchStationDetail(appKey: String, id: String)
    /// 유가 정보를 조회합니다.
    func fetchOilPriceResult(appKey: String) async throws -> [OilPrice]
}
