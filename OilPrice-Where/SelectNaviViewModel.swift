//
//  SelectNaviViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class SelectNaviViewModel: CommonViewModel {
   private let findNavi = [ // 선택 가능한 탐색 반경
      "카카오내비",
      "T map"
   ]
   
   var naviSubject: BehaviorSubject<[String]>
   
   override init() {
      self.naviSubject = BehaviorSubject<[String]>(value: findNavi)
   }
}
