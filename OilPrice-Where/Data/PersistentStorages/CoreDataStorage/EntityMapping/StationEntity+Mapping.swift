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
        self.identifier = station.stationID
        self.name = station.name
        self.brand = station.brand.code
        self.oilType = station.fuelType.code
        self.price = station.recordedPrice
        self.katecX = station.coordinate.katec.x
        self.katecY = station.coordinate.katec.y
        self.insertDate = station.visitDate
    }
}


extension StationEntity {
    func toDomain() -> VisitedGasStation {
        VisitedGasStation(
            stationID: identifier ?? "",
            brand: .init(code: brand ?? ""),
            name: name ?? "",
            fuelType: FuelType(code: oilType ?? ""),
            recordedPrice: price,
            coordinate: .init(x: katecX, y: katecY),
            visitCount: 1,
            visitDate: insertDate ?? Date()
        )
    }
}
