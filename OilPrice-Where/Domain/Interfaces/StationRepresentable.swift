//
//  StationRepresentable.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol StationRepresentable: Hashable {
    var stationID: String { get }
    var brand: StationBrand { get }
    var name: String { get }
    var coordinate: CoordinateSystem { get }
}
