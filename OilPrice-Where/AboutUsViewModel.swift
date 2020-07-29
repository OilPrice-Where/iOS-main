//
//  AboutUsViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/29.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import NSObject_Rx

final class AboutUsViewModel: CommonViewModel {
   private let findNavi = [ // 선택 가능한 탐색 반경
      "카카오내비",
      "T map"
   ]
   
   var naviSubject: BehaviorSubject<[String]>
   
   override init() {
      self.naviSubject = BehaviorSubject<[String]>(value: findNavi)
   }
}
