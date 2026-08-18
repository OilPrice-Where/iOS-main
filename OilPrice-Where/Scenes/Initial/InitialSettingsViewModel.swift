//
//  InitialSettingsViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/03.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine


final class InitialSettingsViewModel {
    //MARK: Properties
    let settingUseCase: SettingUseCase
    
    init(settingUseCase: SettingUseCase) {
        self.settingUseCase = settingUseCase
    }
}

extension InitialSettingsViewModel {
    struct SelectionResult {
        var fuel: FuelType
    }
    
    struct Input {
        /// 모든 설정이 선택 완료 이벤트
        var allSettingsSelectedPublisher: AnyPublisher<SelectionResult, Never>
    }
    
    struct Output {
        /// 메인화면 이동
        var moveMain: AnyPublisher<Void, Never>
    }
    
    func transform(input: Input) -> Output {
        let moveMain = input.allSettingsSelectedPublisher
            .map { [weak self] selection in
                guard let self else {
                    return
                }
                settingUseCase.save(selection.fuel.code, type: .fuelType)
            }
            .eraseToAnyPublisher()
        
        return .init(moveMain: moveMain)
    }
}
