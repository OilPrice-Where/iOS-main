//
//  CoordinateSystem.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import NMapsMap


struct CoordinateSystem {
    var katec: KATEC
    var tm: TM
    
    init(x: Double, y: Double) {
        self.katec = .init(x: x, y: y)
        let latLng = NMGTm128(x: x, y: y).toLatLng()
        self.tm = .init(lat: latLng.lat, lng: latLng.lng)
    }
    
    init(lat: Double, lng: Double) {
        self.tm = .init(lat: lat, lng: lng)
        let tm128 = NMGTm128(from: .init(lat: lat, lng: lng))
        self.katec = .init(x: tm128.x, y: tm128.y)
    }
}


extension CoordinateSystem {
    struct KATEC {
        let x: Double
        let y: Double
    }
    
    struct TM {
        let lat: Double
        let lng: Double
    }
}
