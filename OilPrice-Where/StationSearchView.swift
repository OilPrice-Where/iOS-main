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
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                StationSearchBar(store: self.store)
                
                titleView
                
                if viewStore.state.searchList.isEmpty {
                    Text("최근 검색한 내역이 없습니다.")
                        .font(FontFamily.NanumSquareRound.bold.swiftUIFont(size: 18))
                        .foregroundStyle(.gray)
                        .frame(maxHeight: .infinity)
                } else {
                    
                }
                
                
                Spacer()
            }
            .navigationTitle("주소 검색")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    var titleView: some View {
        HStack {
            Text("최근 검색")
                .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 14))
            
            Spacer()
            
            Button {
                
            } label: {
                Text("전체 삭제")
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 12))
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 16)
    }
}

private struct StationSearchBar: View {
    
    let store: StoreOf<StationSearchReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            HStack {
                Asset.Images.search.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .foregroundStyle(.gray)
                    .frame(width: 20, height: 20)
                    .padding(.trailing, -4)
                
                TextField(
                    "주유소 위치를 검색해보세요.",
                    text: viewStore.$searchText
                )
                .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16))
                
                Spacer()
                
            }
            .frame(height: 24)
            .padding(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.primary, lineWidth: 1)
            )
            .padding(16)
        }
    }
}


#Preview {
    let store = Store(initialState: StationSearchReducer.State()) {
        StationSearchReducer()
    }
    
    return NavigationStack {
        StationSearchView(store: store)
    }
}
