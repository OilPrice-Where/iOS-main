//
//  SearchPOI.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation


struct SearchPOI: Hashable {
    let id = UUID()
    let name: String
    let address: String
    let coordinate: CoordinateSystem
    let insertDate: Date
}
