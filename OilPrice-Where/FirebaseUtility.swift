//
//  FirebaseUtility.swift
//  OilPrice-Where
//
//  Created by SolChan Ahn on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import Moya

class FirebaseUtility {
    var ref: DatabaseReference?
    let staionProvider = MoyaProvider<StationAPI>()
    
    func getAverageCost(productName: String, completion: @escaping (NSDictionary) -> ()) {
        ref = Database.database().reference()
        guard let _ref = ref else { return }
        
        let data = _ref.child("systemData").child("averageCostList").child(productName)
        
        data.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            guard let priceData = snapshot.value as? NSDictionary else {
                completion(["error":"nil Data"])
                return
            }
            
            completion(priceData)
        })
    }
    
    func checkUpdateTime() {
        let date = Date()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "yyyyMMdd"
        let curruntTime = formatter.string(from: date)
        
        ref = Database.database().reference()
        
        guard let _ref = ref else { return }
        
        let data = _ref.child("systemData").child("averageCostList").child("updateTime")
        
        data.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
            let updateTime = snapshot.value as? String ?? ""
            
            if curruntTime != updateTime {
                self.staionProvider.request(.allPrices(appKey: Preferences.getAppKey())) {
                    switch $0 {
                    case .success(let resp):
                        guard let decode = try? resp.map(AllPriceResult.self) else { return }
                        let prices = decode.result.allPriceList
                        
                        for data in prices {
                            var productName = ""
                            switch data.oilCode {
                            case "D047":
                                productName = "dieselCost"
                            case "B027":
                                productName = "gasolinCost"
                            case "K015":
                                productName = "lpgCost"
                            case "B034":
                                productName = "premiumCost"
                            default: break
                            }
                            
                            let priceInteger = Int(data.price.components(separatedBy: ".")[0]) ?? 0
                            let price = Preferences.priceToWon(price: priceInteger)
                            
                            var difference = true
                            let index = data.diff.index(after: data.diff.startIndex)
                            if data.diff[index...] == "-" {
                                difference = false
                            } else {
                                difference = true
                            }
                            
                            let updateCostData = ["difference": difference,
                                                  "price": price] as [String : Any]
                            
                            if productName != "" {
                                _ref.child("systemData")
                                    .child("averageCostList")
                                    .child(productName)
                                    .updateChildValues(updateCostData)
                            }
                            
                        }
                        _ref.child("systemData")
                            .child("averageCostList")
                            .updateChildValues(["updateTime": prices[0].tradeDate])
                    case .failure(let error):
                        LogUtil.e(error.localizedDescription)
                    }
                }
            }
        })
    }
}
