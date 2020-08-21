//
//  SelectMapsViewModel.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/08/21.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class SelectMapsViewModel: CommonViewModel {
   private let mapsType = [ // 선택 가능한 탐색 반경
      "Apple Maps",
      "Google Maps"
   ]
   
   var mapSubject: BehaviorSubject<[String]>
   
   override init() {
      self.mapSubject = BehaviorSubject<[String]>(value: mapsType)
   }
}
