//
//  StationListView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct StationListView: View {
    let store: StoreOf<StationListReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            VStack {
                listHeaderView
                
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(viewStore.stations, id: \.id) { station in
                            StationRow(station: station)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .padding(.horizontal, 16)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
            }
            .background(Asset.Colors.tableViewBackground.swiftUIColor)
            .navigationTitle("주유소 목록")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
//                store.send(.requestAddress)
                store.send(.requestStations)
            }
        }
    }
}

extension StationListView {
    var listHeaderView: some View {
        ListHeaderView(store: store)
            .padding(.top, 16)
            .padding(.horizontal, 12)
            .padding(.bottom, 6)
    }
}

#Preview {
    let store = Store(initialState: StationListReducer.State()) {
        StationListReducer()
    }
    
    return NavigationStack {
        return StationListView(store: store)
    }
}
