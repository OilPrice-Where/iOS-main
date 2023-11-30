//
//  StationSearchStore.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import ComposableArchitecture
import Foundation


@Reducer
struct StationSearchReducer {
    
    struct State: Equatable {
        @BindingState var searchText: String = ""
        
        var searchList: [String] = []
    }
    
    enum Action: BindableAction, Equatable {
        case binding(BindingAction<State>)
    }
    
    var body: some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            return .none
        }
    }
}
