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
    let type: SelectMenuType
    // 선택 가능한 탐색 반경
    private let findNavi = ["카카오내비", "카카오맵", "티맵", "네이버지도"]
    // 선택 가능한 오일 종류
    private let oilType = ["휘발유", "고급휘발유", "경유", "LPG"]
    // 선택 가능한 탐색 반경
    private let findDistaceArea = ["1KM", "3KM", "5KM"]
    
    //MARK: Initializer
    init(type: SelectMenuType) {
        self.type = type
        rxBind()
    }
    
    //MARK: RxBinding..
    func rxBind() {
        input.fetchType
            .bind(with: self, onNext: { owner, type in
                owner.fetchModel()
            })
            .disposed(by: bag)
        
        input.fetchUpdate
            .bind(with: self, onNext: { owner, title in
                owner.fetchUpdated(title: title)
            })
            .disposed(by: bag)
    }
}

//MARK: - I/O & Error
extension SelectMenuViewModel {
    enum SelectMenuType {
        case navigation
        case oilType
        case radius
    }
    
    enum ErrorResult: Error {
        case someError
    }
    
    struct Input {
        let fetchType = PublishRelay<Void?>()
        let fetchUpdate = PublishRelay<String>()
    }
    
    struct Output {
        let fetchModel = PublishRelay<[String]>()
        let fetchTitle = PublishRelay<String>()
        let fetchSelect = PublishRelay<Int>()
    }
}

//MARK: - Method
extension SelectMenuViewModel {
    private func fetchModel() {
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
        
        fetchSelect()
    }
    
    private func fetchSelect() {
        switch type {
        case .navigation:
            output.fetchSelect.accept(findNavi.firstIndex(of: Preferences.navigation(type: DefaultData.shared.naviSubject.value)) ?? 0)
        case .oilType:
            output.fetchSelect.accept(oilType.firstIndex(of: Preferences.oil(code: DefaultData.shared.oilSubject.value)) ?? 0)
        case .radius:
            output.fetchSelect.accept(findDistaceArea.firstIndex(of: Preferences.distanceKM(KM: DefaultData.shared.radiusSubject.value)) ?? 0)
        }
    }
    
    private func fetchUpdated(title: String) {
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
