//
//  FindBrandView.swift
//  OilPrice-Where
//
//  Created by wargi on 11/13/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct FindBrandView: View {
    var store: StoreOf<OilBrandReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                ZStack {
                    Color(.main)
                    Text("검색 브랜드")
                        .foregroundStyle(.white)
                }
                .frame(height: 44)
                
                ForEach(viewStore.state.brands.indices, id: \.self) { index in
                    OilBrandCellView(model: viewStore.state.brands[index].brand,
                                     toggleOn: viewStore.binding(get: {
                        $0.brands[index].isSelected
                    }, send: .toggle(viewStore.state.brands[index]))) { _ in
                        
                    }
                }
                Spacer()
            }
            .onAppear {
                viewStore.send(.fetchBrand)
            }
        }
    }
}

#Preview {
    FindBrandView(store: Store(initialState: OilBrandReducer.State(brands: OilBrand.allCases.map {
        OilBrandModel(oilBrand: $0)
    }), reducer: {
        OilBrandReducer()
    }))
}
