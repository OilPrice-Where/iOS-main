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
    
    let store: StoreOf<StationSearchReducer>
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let store = Store(initialState: StationSearchReducer.State()) {
        StationSearchReducer()
    }
    
    return StationSearchView(store: store)
}
