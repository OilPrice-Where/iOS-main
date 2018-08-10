//
//  Station.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import SwiftyPlistManager

class DefaultData {
    static let shared = DefaultData()
    private init() {
        SwiftyPlistManager.shared.start(plistNames: ["UserInfo"], logging: true)
        
        self.data = nil
        self.radius = SwiftyPlistManager.shared.fetchValue(for: "FindRadius",
                                                             fromPlistWithName: "UserInfo") as! Int
        self.oilType = SwiftyPlistManager.shared.fetchValue(for: "OilType",
                                                            fromPlistWithName: "UserInfo") as! String
    }
    var data: [GasStation]?
    var radius = 0
    var oilType = ""
}
