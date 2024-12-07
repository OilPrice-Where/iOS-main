//
//  InitialViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/03.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine


//MARK: InitialViewModel
final class InitialViewModel {
    var cancelBag = Set<AnyCancellable>()
    
    let fuelTypesPublisher: CurrentValueSubject<[String], Never> = .init(["휘발유", "경유", "고급유", "LPG"])
    let navigationOptionsPublisher: CurrentValueSubject<[String], Never> = .init(["카카오내비", "카카오맵", "티맵", "네이버지도"])
}

extension InitialViewModel {
    enum FuelType: Int {
        case gasoline = 0
        case diesel
        case premium
        case lpg
    }
    
    enum NavigationService: Int {
        case kakao = 0
        case kakaoMap
        case tmap
        case naverMap
    }
    
    struct UserSelection {
        var fuel: FuelType
        var navigation: NavigationService
    }
    
    struct Input {
        /// 유종, 내비게이션 선택 완료 이벤트
        var okActionPublisher: AnyPublisher<UserSelection, Never>
    }
    
    struct Output {
        /// 메인화면 이동
        var moveMain: AnyPublisher<Void, Never>
    }
    
    func transform(input: Input) -> Output {
        let moveMain = input.okActionPublisher
            .map { selection in
                DefaultData.shared.oilSubject.send(self.select(fuel: selection.fuel))
                DefaultData.shared.naviSubject.send(self.select(navigation: selection.navigation))
            }
            .eraseToAnyPublisher()
        
        return .init(moveMain: moveMain)
    }
}


//MARK: Method
extension InitialViewModel {
    func select(fuel: FuelType) -> String {
        switch fuel {
        case .gasoline:
            return "B027" // 첫번째 페이지 선택 휘발유
        case .diesel:
            return "D047" // 두번째 페이지 선택 경유
        case .lpg:
            return "K015" // 세번째 페이지 선택 LPG
        case .premium:
            return "B034" // 네번째 페이지 선택 고급휘발유
        }
    }
    
    func select(navigation: NavigationService) -> String {
        switch navigation {
        case .kakao:
            return "kakao"
        case .tmap:
            return "tMap"
        case .kakaoMap:
            return "kakaoMap"
        case .naverMap:
            return "naverMap"
        }
    }
}
