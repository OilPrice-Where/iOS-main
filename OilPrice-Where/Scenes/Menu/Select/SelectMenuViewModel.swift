//
//  SelectMenuViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine

//MARK: SelectMenuViewModel
final class SelectMenuViewModel {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let input = Input()
    let output = Output()
    let type: SelectMenuType
    // 선택 가능한 탐색 반경
    private let findNavi = ["카카오내비", "카카오맵", "티맵", "네이버지도"]
    // 선택 가능한 오일 종류
    private let oilType = ["휘발유", "고급휘발유", "경유", "LPG"]
    // 선택 가능한 탐색 반경
    private let findDistaceArea = ["1KM", "3KM", "5KM"]
    private let backgroundFind = ["켜기", "끄기"]
    
    //MARK: Initializer
    init(type: SelectMenuType) {
        self.type = type
        bind()
    }
    
    //MARK: Binding..
    func bind() {
        input.fetchType
            .sink { [weak self] type in
                guard let owner = self else { return }
                owner.fetchModel()
            }
            .store(in: &cancelBag)
        
        input.fetchUpdate
            .sink { [weak self] title in
                guard let owner = self else { return }
                owner.fetchUpdated(title: title)
            }
            .store(in: &cancelBag)
    }
}

//MARK: - I/O & Error
extension SelectMenuViewModel {
    enum SelectMenuType {
        case navigation
        case oilType
        case background
    }
    
    enum ErrorResult: Error {
        case someError
    }
    
    struct Input {
        let fetchType = PassthroughSubject<Void?, Never>()
        let fetchUpdate = PassthroughSubject<String, Never>()
    }
    
    struct Output {
        let fetchModel = PassthroughSubject<[String], Never>()
        let fetchTitle = PassthroughSubject<String, Never>()
        let fetchSelect = PassthroughSubject<Int, Never>()
    }
}

//MARK: - Method
extension SelectMenuViewModel {
    private func fetchModel() {
        switch type {
        case .navigation:
            output.fetchModel.send(findNavi)
            output.fetchTitle.send("연동할 내비게이션을 선택해 주세요.")
        case .oilType:
            output.fetchModel.send(oilType)
            output.fetchTitle.send("찾으시는 유종을 선택해 주세요.")
        case .background:
            output.fetchModel.send(backgroundFind)
            output.fetchTitle.send("백그라운드 탐색 여부를 선택해 주세요.")
        }
        
        fetchSelect()
    }
    
    private func fetchSelect() {
        switch type {
        case .navigation:
            output.fetchSelect.send(findNavi.firstIndex(of: Preferences.navigation(type: DefaultData.shared.naviSubject.value)) ?? 0)
        case .oilType:
            output.fetchSelect.send(oilType.firstIndex(of: Preferences.oil(code: DefaultData.shared.oilSubject.value)) ?? 0)
        case .background:
            output.fetchSelect.send(DefaultData.shared.backgroundFindSubject.value ? 0 : 1)
        }
    }
    
    private func fetchUpdated(title: String) {
        switch type {
        case .navigation:
            DefaultData.shared.naviSubject.send(Preferences.navigation(name: title))
        case .oilType:
            DefaultData.shared.oilSubject.send(Preferences.oil(name: title))
        case .background:
            let isOn = "켜기" == title
            DefaultData.shared.backgroundFindSubject.send(isOn)
            
            if #available(iOS 16.1, *) {
                if isOn, !(ActivityManager.shared.activity?.activityState == .active) {
                    ActivityManager.shared.configure()
                } else if !isOn {
                    Task {
                        await ActivityManager.shared.endActivity()
                    }
                }
            }
        }
    }
}
