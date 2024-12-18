//
//  StationEntity+Mapping.swift
//  OilPrice-Where
//
//  Created by wargi on 1/21/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import CoreData


extension StationEntity {
    convenience init(visitedStation station: VisitedGasStation,
                     insertInto context: NSManagedObjectContext) {
        self.init(context: context)
        self.identifier = station.id
        self.name = station.name
        self.brand = station.brand
        self.oilType = station.fuelCode
        self.price = station.recordedPrice
        self.katecX = station.katecX
        self.katecY = station.katecY
        self.insertDate = Date()
    }
}


extension StationEntity {
    func toDomain() -> VisitedGasStation {
        VisitedGasStation(
            id: identifier ?? "",
            brand: brand ?? "",
            name: name ?? "",
            fuelCode: oilType ?? "",
            recordedPrice: price,
            visitDate: insertDate ?? Date(),
            katecX: katecX,
            katecY: katecY
        )
    }
}
