//
//  CoreDataVisitedStationStorage.swift
//  OilPrice-Where
//
//  Created by wargi on 1/21/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import CoreData
import Foundation


final class CoreDataVisitedStationStorage: VisitedStationStorage {

    private let manager = DataManager.shared
    
    func fetchVisitedStations() -> [VisitedGasStation] {
        let stationRequest: NSFetchRequest<StationEntity> = StationEntity.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        stationRequest.sortDescriptors = [sortByDateDesc]
                
        guard let stationEntities = try? manager.fetch(request: stationRequest) else {
            return []
        }
        
        return stationEntities.map {
            $0.toDomain()
        }
    }
    
    func saveVisited(station: VisitedGasStation) async throws -> VisitedGasStation {
        try await withCheckedThrowingContinuation { continuation in
            manager.performBackgroundTask { context in
                do {
                    let entity = StationEntity(visitedStation: station, insertInto: context)
                    try context.save()
                    continuation.resume(returning: entity.toDomain())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func removeVisited(station: VisitedGasStation) async throws {
        try await withCheckedThrowingContinuation { continuation in
            manager.performBackgroundTask { [weak self] context in
                do {
                    try self?.remove(station: station, inContext: context)
                    try context.save()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


private extension CoreDataVisitedStationStorage {
    func remove(station: VisitedGasStation,
                inContext context: NSManagedObjectContext) throws {
        let request: NSFetchRequest = StationEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "insertDate", ascending: false)]
        
        try context.fetch(request)
            .filter { $0.insertDate == station.visitDate && $0.identifier == station.id }
            .forEach { context.delete($0) }
    }
}
