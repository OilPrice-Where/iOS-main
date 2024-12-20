//
//  Int+.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


extension Int {
    private static var numberFormatter = NumberFormatter().then {
        $0.numberStyle = .decimal
    }
    
    var decimalNumber: String {
        return Int.numberFormatter.string(from: NSNumber(integerLiteral: self)) ?? "0"
    }
}
