//
//  ResponsePOI.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import CoreLocation

struct ResponsePOI: Hashable {
    var id = UUID()
    var name: String?
    let address: String?
    let coordinate: CLLocationCoordinate2D?
    let insertDate: Date?
}

extension ResponsePOI {
    static func == (lhs: ResponsePOI, rhs: ResponsePOI) -> Bool {
        return lhs.name == rhs.name &&
                lhs.coordinate?.latitude == rhs.coordinate?.latitude &&
                lhs.coordinate?.longitude == rhs.coordinate?.longitude &&
                lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(name)
        hasher.combine(coordinate?.latitude)
        hasher.combine(coordinate?.longitude)
    }
}
