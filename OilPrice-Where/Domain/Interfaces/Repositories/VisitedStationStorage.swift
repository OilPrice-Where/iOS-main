//
//  VisitedStationStorage.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol VisitedStationStorage {
    func fetchVisitedStations() -> [VisitedGasStation]
    @discardableResult
    func saveVisited(station: VisitedGasStation) async throws -> VisitedGasStation
    func removeVisited(station: VisitedGasStation) async throws
}
