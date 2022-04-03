//
//  FindNavigationViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import RxRelay
//MARK: FindNavigationViewModel
final class FindNavigationViewModel {
    private let findNavi = [ // 선택 가능한 탐색 반경
        "카카오내비",
        "카카오맵",
        "티맵",
        "네이버지도"
    ]
    
    var naviSubject: BehaviorRelay<[String]>
    
    init() {
        self.naviSubject = BehaviorRelay<[String]>(value: findNavi)
    }
}
