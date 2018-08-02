//
//  serviceUtility.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 7. 27..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation

struct Appkey {
    func get() -> String {
        var appKey = ""
        
        switch arc4random_uniform(6) {
        case 0:
            appKey = "F302180619"
        case 1:
            appKey = "F303180619"
        case 2:
            appKey = "F304180619"
        case 3:
            appKey = "F305180619"
        case 4:
            appKey = "F306180619"
        default:
            appKey = "F307180619"
        }
        return appKey
    }
}
