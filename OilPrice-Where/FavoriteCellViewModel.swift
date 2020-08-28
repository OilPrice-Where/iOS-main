//
//  FavoriteCellViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/02.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import UIKit
import RxSwift

final class FavoriteCellViewModel {
   let bag = DisposeBag()
   private var info: InformationGasStaion?
   var infoSubject = BehaviorSubject<InformationGasStaion?>(value: nil)
   var isLoadingSubject = BehaviorSubject<Bool>(value: false)
   
   private func getStationsInfo(id: String) {
      ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                       id: id) { (result) in
         switch result {
         case .success(let infomation):
            self.info = infomation
            self.infoSubject.onNext(infomation)
            self.isLoadingSubject.onNext(true)
         case .error(_):
            break
         }
      }
   }
   
   // 가격 정보 얻기
   func displayPriceInfomation(priceList: [Price]?) -> String {
      guard let type = try? DefaultData.shared.oilSubject.value(),
         let displayInfo = priceList?.first(where: { $0.type == type }) else { return  "가격정보 없음" }
      
      let price = Preferences.priceToWon(price: displayInfo.price)
      
      return price
   }
   
   // 컬러 값 얻기
   func getActivatedColor(info: String?) -> UIColor {
      guard let mainColor = UIColor(named: "MainColor") else { return .lightGray }
      let isActive = info == "Y"
      
      return isActive ? mainColor : .lightGray
   }
   
   // 즐겨찾기 삭제
   func deleteAction() {
      guard let oldFavArr = try? DefaultData.shared.favoriteSubject.value(),
            let info = info else { return }
      
      let newFavArr = oldFavArr.filter { info.id != $0 }
      DefaultData.shared.favoriteSubject.onNext(newFavArr)
   }
   
   // 길 안내
   func navigationButton() {
      guard let navi = try? DefaultData.shared.naviSubject.value(),
            let info = info else { return }
      
      NotificationCenter.default.post(name: NSNotification.Name("navigationClickEvent"),
                                      object: nil,
                                      userInfo: ["katecX": info.katecX.roundTo(places: 0),
                                                 "katecY": info.katecY.roundTo(places: 0),
                                                 "stationName": info.name,
                                                 "naviType": navi])
   }
   
   init(id: String) {
      self.getStationsInfo(id: id)
   }
}
