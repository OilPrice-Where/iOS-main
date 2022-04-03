//
//  MenuViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: MenuViewModel
final class MenuViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
    let output = Output()
    
    //MARK: Initializer
    init() {
        rxBind()
    }
    
    //MARK: RxBinding..
    func rxBind() {
        
    }
}

//MARK: - I/O & ErrorMenuViewModel
extension MenuViewModel {
    struct Output {
        //MARK: Functions..
        // 이전 설정을 데이터를 불러와서
        // oilTypeLabel, findLabel 업데이트
        func fetchNavigationTitle() -> Observable<String?> {
            return Observable.just(Preferences.navigation(type: DefaultData.shared.naviSubject.value))
        }
        
        func fetchOilTypeString() -> Observable<String?> {
            return Observable.just(Preferences.oil(code: DefaultData.shared.oilSubject.value))
        }
        
        func fetchDistanceString() -> Observable<String?> {
            return Observable.just(String(DefaultData.shared.radiusSubject.value / 1000) + "KM")
        }
    }
}
