//
//  ListHeaderView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


struct ListHeaderView: View {
    
    let store: StoreOf<StationListReducer>
    
    var body: some View {
        WithViewStore(store, observe: { $0 }) { viewStore in
            HStack {
                Button {
                    viewStore.send(.orderByPrice)
                } label: {
                    Text("가격순")
                        .font(viewStore.state.isOrderByPrice ? FontFamily.NanumSquareRound.extraBold.swiftUIFont(size: 16) : FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16))
                        .foregroundStyle(viewStore.state.isOrderByPrice ? Asset.Colors.mainColor.swiftUIColor : Asset.Colors.defaultColor.swiftUIColor)
                }

                Button {
                    viewStore.send(.orderByDistance)
                } label: {
                    Text("거리순")
                        .font(viewStore.state.isOrderByPrice ? FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16) : FontFamily.NanumSquareRound.extraBold.swiftUIFont(size: 16))
                        .foregroundStyle(viewStore.state.isOrderByPrice ? Asset.Colors.defaultColor.swiftUIColor : Asset.Colors.mainColor.swiftUIColor)
                }
                
                Spacer()
                
                Asset.Images.geoIcon.swiftUIImage
                    .renderingMode(.template)
                    .resizable()
                    .tint(.black)
                    .frame(width: 16, height: 16)
                    .padding(.trailing, -8)
                
                Text(viewStore.state.address)
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 14))
            }
        }
    }
}

#Preview {
    ListHeaderView(store: Store(initialState: StationListReducer.State(),
                                reducer: {
       StationListReducer()
   }))
}
