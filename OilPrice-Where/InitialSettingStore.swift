//
//  InitialSettingStore.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture


@Reducer
struct InitialSettingReducer {
    struct State: Equatable {
        var oilType: OilType = .gasoline
        var navigationType: NavigationType = .kakao
        
        
        @BindingState var isSheetVisible: Bool = false
        
        enum Screen: Int, CaseIterable, Identifiable, Hashable {
            case stationList
            
            var id: Int { self.rawValue }
        }
        
        enum OilType: String, CaseIterable {
            case gasoline = "휘발유"
            case diesel = "경유"
            case premium = "고급유"
            case lpg = "LPG"
            
            var code: String {
                switch self {
                case .gasoline:
                    "B027" // 첫번째 페이지 선택 휘발유
                case .diesel:
                    "D047" // 두번째 페이지 선택 경유
                case .lpg:
                    "K015" // 세번째 페이지 선택 LPG
                case .premium:
                    "B034" // 네번째 페이지 선택 고급휘발유
                }
            }
        }
        
        enum NavigationType: String, CaseIterable {
            case kakao = "카카오내비"
            case kakaoMap = "카카오맵"
            case tmap = "티맵"
            case naverMap = "네이버지도"
            
            var code: String {
                switch self {
                case .kakao:
                    "kakao"
                case .tmap:
                    "tMap"
                case .kakaoMap:
                    "kakaoMap"
                case .naverMap:
                    "naverMap"
                }
            }
        }
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case oilTypeChanged(State.OilType)
        case navigationTypeChanged(State.NavigationType)
        case okButtonTapped
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(_):
                return .none
                
            case .oilTypeChanged(let oil):
                state.oilType = oil
                return .none
                
            case .navigationTypeChanged(let navigation):
                state.navigationType = navigation
                return .none
                
            case .okButtonTapped:
                DefaultData.shared.oilSubject.send(state.oilType.code)
                DefaultData.shared.naviSubject.send(state.navigationType.code)
                
                state.isSheetVisible = true
                
                return .none
            }
        }
    }
}
