//
//  StationSearchView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct StationSearchView: View {
    
    let store: StoreOf<SearchReducer>
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let store = Store(initialState: SearchReducer.State()) {
        SearchReducer()
    }
    
    return StationSearchView(store: store)
}
