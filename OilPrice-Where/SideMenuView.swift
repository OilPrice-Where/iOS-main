//
//  SideMenuView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct SideMenuView: View {
    
    let store: StoreOf<SideMenuReducer>
    
    var body: some View {
        Text("Hello, World!")
    }
}

#Preview {
    let store = Store(initialState: SideMenuReducer.State()) {
        SideMenuReducer()
    }
    
    return SideMenuView(store: store)
}
