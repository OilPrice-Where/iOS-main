//
//  CoreDataSearchPOIStorage.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import CoreData
import Foundation


final class CoreDataSearchPOIStorage: SearchPOIStorage {

    private let manager = DataManager.shared
    
    func fetchSearchPOIs() -> [SearchPOI] {
        let poiRequest: NSFetchRequest<POIEntity> = POIEntity.fetchRequest()
        let sortByDateDesc = NSSortDescriptor(key: "insertDate", ascending: false)
        poiRequest.sortDescriptors = [sortByDateDesc]
                
        guard let poiEntities = try? manager.fetch(request: poiRequest) else {
            return []
        }
        
        return poiEntities.map {
            $0.toDomain()
        }
    }
    
    @discardableResult
    func saveSearch(poi: SearchPOI) async throws -> SearchPOI {
        try await withCheckedThrowingContinuation { continuation in
            manager.performBackgroundTask { context in
                do {
                    let entity = POIEntity(searchPOI: poi, insertInto: context)
                    try context.save()
                    continuation.resume(returning: entity.toDomain())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
    
    func removeSearch(poi: SearchPOI) async throws {
        try await withCheckedThrowingContinuation { continuation in
            manager.performBackgroundTask { [weak self] context in
                do {
                    try self?.remove(poi: poi, inContext: context)
                    try context.save()
                    continuation.resume(returning: ())
                } catch {
                    continuation.resume(throwing: error)
                }
            }
        }
    }
}


private extension CoreDataSearchPOIStorage {
    func remove(poi: SearchPOI, inContext context: NSManagedObjectContext) throws {
        let request: NSFetchRequest = POIEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "insertDate", ascending: false)]
        
        try context.fetch(request)
            .filter {
                $0.name == poi.name &&
                $0.address == poi.address &&
                $0.latitude == poi.coordinate.tm.lat &&
                $0.longitude == poi.coordinate.tm.lng &&
                $0.insertDate == poi.insertDate
            }
            .forEach { context.delete($0) }
    }
}
