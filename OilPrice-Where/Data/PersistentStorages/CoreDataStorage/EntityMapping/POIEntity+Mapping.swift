//
//  POIEntity+Mapping.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import CoreData


extension POIEntity {
    convenience init(searchPOI poi: SearchPOI,
                     insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.name = poi.name
        self.address = poi.address
        self.latitude = poi.coordinate.tm.lat
        self.longitude = poi.coordinate.tm.lng
        self.insertDate = poi.insertDate
    }
}


extension POIEntity {
    func toDomain() -> SearchPOI {
        .init(
            name: name ?? "",
            address: address ?? "",
            coordinate: CoordinateSystem(lat: latitude, lng: longitude),
            insertDate: insertDate ?? Date()
        )
    }
}
