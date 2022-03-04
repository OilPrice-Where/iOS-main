//
//  FindOilTypeViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay

final class FindOilTypeViewModel {
    private let OilType = [ // 선택 가능한 오일 종류
        "휘발유",
        "고급휘발유",
        "경유",
        "LPG"
    ]
    var oilSubject: BehaviorRelay<[String]>
    
    init() {
        self.oilSubject = BehaviorRelay<[String]>(value: OilType)
    }
}
