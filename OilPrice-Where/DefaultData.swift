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
    var priceData: [AllPrice] = []
    var radius = 0
    var oilType = ""
    
    func save() {
        // Oil Type Save
        SwiftyPlistManager.shared.save(DefaultData.shared.oilType,
                                       forKey: "OilType",
                                       toPlistWithName: "UserInfo") { (err) in
                                        if err != nil {
                                            print("Success Save Oil Type !!")
                                        }
        }
        // Find Radius Value Save
        SwiftyPlistManager.shared.save(DefaultData.shared.radius,
                                       forKey: "FindRadius",
                                       toPlistWithName: "UserInfo") { (err) in
                                        if err != nil {
                                            print("Success Save Distance !!")
                                        }
        }
    }
    
    func allPriceDataLoad() {
        ServiceList.allPriceList(appKey: Preferences.getAppKey()) { (result) in
            switch result {
            case .success(let allPriceListData):
                self.priceData = allPriceListData.result.allPriceList
            case .error(let err):
                print(err)
            }
        }
    }
}
