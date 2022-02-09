//
//  InitialViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/03.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift

typealias InitialOilType = (name: String, image: UIImage?)

final class InitialViewModel {
   enum SelectOilStyle: Int {
      case gasoline = 0
      case diesel = 1
      case premium = 2
      case lpg = 3
   }
   
   enum SelectNaviStyle: Int {
      case kakao = 0
      case tmap = 1
   }
   
   enum SelectMapStyle: Int {
      case appleMap = 0
      case googleMap = 1
   }
   
   func select(oil index: Int) -> String {
      var selectedOil = "B027"
      guard let style = SelectOilStyle(rawValue: index) else { return selectedOil }
      
      switch style {
         case .gasoline:
            selectedOil = "B027" // 첫번째 페이지 선택 휘발유
         case .diesel:
            selectedOil = "D047" // 두번째 페이지 선택 경유
         case .lpg:
            selectedOil = "K015" // 세번째 페이지 선택 LPG
         case .premium:
            selectedOil = "B034" // 네번째 페이지 선택 고급휘발유
      }
      
      return selectedOil
   }
   
   func select(navi index: Int) -> String {
      var selectedNavi = "kakao"
      guard let style = SelectNaviStyle(rawValue: index) else { return selectedNavi }
      
      switch style {
      case .kakao:
         selectedNavi = "kakao"
      case .tmap:
         selectedNavi = "tmap"
      }
      
      return selectedNavi
   }
   
   func select(map index: Int) -> String {
      var selectMap = "AppleMap"
      guard let style = SelectMapStyle(rawValue: index) else { return selectMap }
      
      switch style {
      case .appleMap:
         selectMap = "AppleMap"
      case .googleMap:
         selectMap = "GoogleMap"
      }
      
      return selectMap
   }
   
   func okAction(oil: Int, navi: Int, map: Int) {
      DefaultData.shared.oilSubject.onNext(select(oil: oil))
      DefaultData.shared.naviSubject.onNext(select(navi: navi))
      DefaultData.shared.mapsSubject.onNext(select(map: map))
   }
}
