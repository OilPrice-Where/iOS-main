//
//  FavoriteStore.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import ComposableArchitecture
import Foundation


@Reducer
struct FavoriteReducer {
    
    struct State: Equatable {
        
    }
    
    enum Action: Equatable {
        
    }
    
    var body: some Reducer<State, Action> {
        
        Reduce { state, action in
            return .none
        }
    }
}






