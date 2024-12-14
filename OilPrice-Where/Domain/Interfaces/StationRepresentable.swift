//
//  StationRepresentable.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol StationRepresentable {
    var id: String { get }
    var brand: String { get }
    var name: String { get }
    var katecX: Double { get }
    var katecY: Double { get }
}
