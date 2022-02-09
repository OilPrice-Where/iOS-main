//
//  SelectStationViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class SelectStationViewModel: CommonViewModel {
   private let findBrand = [ // 선택 가능한 탐색 반경
      "전체",
      "SK에너지",
      "현대오일뱅크",
      "GS칼텍스",
      "S-OIL",
      "SK가스",
      "자영알뜰",
      "E1",
      "자가상표",
      "농협알뜰",
      "고속도로알뜰"
   ]
   
   var brandSubject: BehaviorSubject<[String]>
   
   override init() {
      self.brandSubject = BehaviorSubject<[String]>(value: findBrand)
   }
}
