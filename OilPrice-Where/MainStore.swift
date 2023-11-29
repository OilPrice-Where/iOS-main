//
//  MainStore.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import ComposableArchitecture
import Foundation


@Reducer
struct MainReducer {
    struct State: Equatable {
        var sideMenu = SideMenuReducer.State()
        var search = StationSearchReducer.State()
        var stationList = StationListReducer.State()
        var favorite = FavoriteReducer.State()
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
        case side(SideMenuReducer.Action)
        case search(StationSearchReducer.Action)
        case stationList(StationListReducer.Action)
        case favorite(FavoriteReducer.Action)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Scope(state: \.sideMenu, action: /Action.side) {
            SideMenuReducer()
        }
        Scope(state: \.search, action: /Action.search) {
            StationSearchReducer()
        }
        Scope(state: \.stationList, action: /Action.stationList) {
            StationListReducer()
        }
        Scope(state: \.favorite, action: /Action.favorite) {
            FavoriteReducer()
        }
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .side:
                return .none
            case .search:
                return .none
            case .stationList:
                return .none
            case .favorite:
                return .none
            }
        }
    }
}
