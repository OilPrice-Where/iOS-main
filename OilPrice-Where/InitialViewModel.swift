//
//  InitialViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/03.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift

typealias InitialOilType = (String, UIImage?)

enum SelectInitialPage: Int {
   case gasoline = 0
   case diesel = 1
   case lpg = 2
   case premium = 3
}

final class InitialViewModel {
   private let initialOilTypes: [InitialOilType] = [
      ("휘발유", UIImage(named: "gasolinImage")),
      ("경유", UIImage(named: "dieselImage")),
      ("LPG", UIImage(named: "lpgImage")),
      ("고급유", UIImage(named: "premiumImage"))
   ]
   lazy var initialOilTypeSubject: BehaviorSubject<[InitialOilType]> = {
      let subject = BehaviorSubject<[InitialOilType]>(value: initialOilTypes)
      
      return subject
   }()
   
   func okAction(page: SelectInitialPage) {
      var selectedOil = ""
      
      switch page {
      case .gasoline:
         selectedOil = "B027" // 첫번째 페이지 선택 휘발유
      case .diesel:
         selectedOil = "D047" // 두번째 페이지 선택 경유
      case .lpg:
         selectedOil = "K015" // 세번째 페이지 선택 LPG
      case .premium:
         selectedOil = "B034" // 네번째 페이지 선택 고급휘발유
      }
      
      DefaultData.shared.oilSubject.onNext(selectedOil)
   }
}
