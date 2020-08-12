//
//  EditSalePriceViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class EditSalePriceViewModel: CommonViewModel {
   private let showBrand = [ // 선택 가능한 탐색 반경
      "SK 에너지/가스",
      "현대오일뱅크",
      "GS칼텍스",
      "S-OIL",
      "E1",
      "알뜰주유소",
      "농협",
      "남해화학클린"
   ]
   
   var brandSubject: BehaviorSubject<[String]>
   
   override init() {
      self.brandSubject = BehaviorSubject<[String]>(value: showBrand)
   }
}
