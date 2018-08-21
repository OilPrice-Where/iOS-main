//
//  FirebaseUtility.swift
//  OilPrice-Where
//
//  Created by SolChan Ahn on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUtility {
    func setCost(productName: String) {
        var ref: DatabaseReference!
        
        ref = Database.database().reference()
        let data = ref.child("systemData").child("averageCostList").child(productName)
        
        data.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            
        })
    }
    
    func getCurruntTime() -> String{
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd"
        let result = formatter.string(from: date)
        return result
    }
}
