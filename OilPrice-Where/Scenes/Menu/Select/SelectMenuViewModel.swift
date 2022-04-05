//
//  SelectMenuViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

//MARK: SelectMenuViewModel
final class SelectMenuViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
    let input = Input()
    let output = Output()
    // 선택 가능한 탐색 반경
    private let findNavi = ["카카오내비", "카카오맵", "티맵", "네이버지도"]
    // 선택 가능한 오일 종류
    private let oilType = ["휘발유", "고급휘발유", "경유", "LPG"]
    // 선택 가능한 탐색 반경
    private let findDistaceArea = ["1KM", "3KM", "5KM"]
    
    //MARK: Initializer
    init() {
        rxBind()
    }
    
    //MARK: RxBinding..
    func rxBind() {
        input.fetchType
            .bind(with: self, onNext: { owner, type in
                owner.fetchModel(type: type)
            })
            .disposed(by: bag)
    }
}

//MARK: - I/O & Error
extension SelectMenuViewModel {
    enum ErrorResult: Error {
        case someError
    }
    
    struct Input {
        let fetchType = PublishRelay<SelectMenuVC.SelectMenuType>()
    }
    
    struct Output {
        let fetchModel = PublishRelay<[String]>()
        let fetchTitle = PublishRelay<String>()
    }
}

//MARK: - Method
extension SelectMenuViewModel {
    func fetchModel(type: SelectMenuVC.SelectMenuType) {
        switch type {
        case .navigation:
            output.fetchModel.accept(findNavi)
            output.fetchTitle.accept("연동할 내비게이션을 선택해 주세요.")
        case .oilType:
            output.fetchModel.accept(oilType)
            output.fetchTitle.accept("찾으시는 유종을 선택해 주세요.")
        case .radius:
            output.fetchModel.accept(findDistaceArea)
            output.fetchTitle.accept("주유소 탐색 반경을 선택해 주세요.")
        }
    }
    
    func fetchSelect(type: SelectMenuVC.SelectMenuType) -> String {
        switch type {
        case .navigation:
            return Preferences.navigation(type: DefaultData.shared.naviSubject.value)
        case .oilType:
            return Preferences.oil(code: DefaultData.shared.oilSubject.value)
        case .radius:
            return Preferences.distanceKM(KM: DefaultData.shared.radiusSubject.value)
        }
    }
    
    func fetchUpdated(type: SelectMenuVC.SelectMenuType, title: String) {
        switch type {
        case .navigation:
            DefaultData.shared.naviSubject.accept(Preferences.navigation(name: title))
        case .oilType:
            DefaultData.shared.oilSubject.accept(Preferences.oil(name: title))
        case .radius:
            DefaultData.shared.radiusSubject.accept(Preferences.distanceKM(KM: title))
        }
    }
}
