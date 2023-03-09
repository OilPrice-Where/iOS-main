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
    typealias InitialOilType = (name: String, image: UIImage?)
    
    enum SelectOilStyle: Int {
        case gasoline = 0
        case diesel = 1
        case premium = 2
        case lpg = 3
    }
    
    enum SelectNaviStyle: Int {
        case kakao = 0
        case kakaoMap
        case tmap
        case naverMap
    }
}
//MARK: Method
extension InitialViewModel {
    func select(oil index: Int) -> String {
        var selectedOil = "B027"
        guard let style = SelectOilStyle(rawValue: index) else { return selectedOil }
        
        switch style {
        case .gasoline:
            selectedOil = "B027" // 첫번째 페이지 선택 휘발유
        case .diesel:
            selectedOil = "D047" // 두번째 페이지 선택 경유
        case .lpg:
            selectedOil = "K015" // 세번째 페이지 선택 LPG
        case .premium:
            selectedOil = "B034" // 네번째 페이지 선택 고급휘발유
        }
        
        return selectedOil
    }
    
    func select(navi index: Int) -> String {
        var selectedNavi = "kakao"
        guard let style = SelectNaviStyle(rawValue: index) else { return selectedNavi }
        
        switch style {
        case .kakao:
            selectedNavi = "kakao"
        case .tmap:
            selectedNavi = "tMap"
        case .kakaoMap:
            selectedNavi = "kakaoMap"
        case .naverMap:
            selectedNavi = "naverMap"
        }
        
        return selectedNavi
    }
    
    func okAction(oil: Int, navi: Int) {
        DefaultData.shared.oilSubject.send(select(oil: oil))
        DefaultData.shared.naviSubject.accept(select(navi: navi))
    }
}
