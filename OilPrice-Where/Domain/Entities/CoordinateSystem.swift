//
//  CoordinateSystem.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import NMapsMap


struct CoordinateSystem: Hashable {
    var katec: KATEC
    var tm: TM
    
    init(x: Double?, y: Double?) {
        let katec: KATEC = .init(x: x ?? 465535.79052, y: y ?? 351548.26588)
        self.katec = katec
        
        let latLng = NMGTm128(x: katec.x, y: katec.y).toLatLng()
        self.tm = .init(lat: latLng.lat, lng: latLng.lng)
    }
    
    init(lat: Double, lng: Double) {
        self.tm = .init(lat: lat, lng: lng)
        let tm128 = NMGTm128(from: .init(lat: lat, lng: lng))
        self.katec = .init(x: tm128.x, y: tm128.y)
    }
}


extension CoordinateSystem {
    struct KATEC: Hashable {
        let x: Double
        let y: Double
    }
    
    struct TM: Hashable {
        let lat: Double
        let lng: Double
    }
}


extension CoordinateSystem {
    var location: CLLocation {
        .init(latitude: tm.lat, longitude: tm.lng)
    }
}
