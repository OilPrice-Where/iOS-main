//
//  Double+.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


extension Double {
    var kmString: String {
        self < 1000 ? "\(Int(self))m" : String(format: "%.1fkm", self / 1000)
    }
    
    /// 반올림
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
