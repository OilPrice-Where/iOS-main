//
//  FavoriteView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


struct FavoriteView: View {
    
    let store: StoreOf<FavoriteReducer>
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let store = Store(initialState: FavoriteReducer.State()) {
        FavoriteReducer()
    }
    
    return FavoriteView(store: store)
}
