//
//  SelectDistanceViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class SelectDistanceViewModel: CommonViewModel {
   let findDistaceArea = [ // 선택 가능한 탐색 반경
      "1KM",
      "3KM",
      "5KM"
   ]
   
   var distanceSubject: BehaviorSubject<[String]>
   
   override init() {
      self.distanceSubject = BehaviorSubject<[String]>(value: findDistaceArea)
   }
}
