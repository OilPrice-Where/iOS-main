//
//  MainView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import Foundation
import SwiftUI
import ComposableArchitecture


struct MainView: View {
    
    let store: StoreOf<MainReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            NavigationView {
                ZStack {
                    NaverMapView()
                        .ignoresSafeArea()
                    
                    VStack {
                        HStack {
                            sideMenuButton
                                .padding(.leading, 8)
                            
                            searchButton
                            
                            Spacer()
                            
                            listButton
                                .padding(8)
                        }
                        .background(.white)
                        .frame(height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: 28))
                        .shadow(radius: 2.5, x: 2.5, y: 2.5)
                        .padding(.horizontal, 24)
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            favoriteButton
                                .padding(.horizontal, 8)
                            currentLocationButton
                        }
                        .padding(.horizontal, 24)
                    }
                }
            }
        }
    }
    
    /// SideMenu 이동 버튼
    var sideMenuButton: some View {
        NavigationLink {
            SideMenuView(
                store: self.store.scope(
                    state: \.sideMenu,
                    action: MainReducer.Action.side
                )
            )
        } label: {
            ZStack {
                Asset.Images.menuIcon.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .tint(Asset.Colors.mainColor.swiftUIColor)
                    .frame(width: 32, height: 32)
            }
            .frame(width: 40, height: 40)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }

    }
    
    /// Search 페이지 이동 버튼
    var searchButton: some View {
        NavigationLink {
            StationSearchView(
                store: self.store.scope(
                    state: \.search,
                    action: MainReducer.Action.search
                )
            )
        } label: {
            HStack {
                Asset.Images.search.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .tint(.gray)
                    .frame(width: 20, height: 20)
                    .padding(.trailing, -4)
                
                Text("주유소 위치를 검색해보세요.")
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 14))
                    .foregroundStyle(.gray)
            }
        }
    }
    
    /// List 페이지 이동 버튼
    var listButton: some View {
        NavigationLink {
            StationListView(
                store: self.store.scope(
                    state: \.stationList,
                    action: MainReducer.Action.stationList
                )
            )
        } label: {
            ZStack {
                Asset.Images.listIcon.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .tint(.white)
                    .frame(width: 26, height: 26)
            }
            .frame(width: 40, height: 40)
            .background(Asset.Colors.mainColor.swiftUIColor)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
    
    /// 즐겨찾기 페이지 이동 버튼
    var favoriteButton: some View {
        NavigationLink {
            FavoriteView(
                store: self.store.scope(
                    state: \.favorite,
                    action: MainReducer.Action.favorite
                )
            )
        } label: {
            ZStack {
                Asset.Images.favoriteIcon.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .tint(Asset.Colors.mainColor.swiftUIColor)
                    .frame(width: 26, height: 26)
            }
            .frame(width: 40, height: 40)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 2.5, x: 2.5, y: 2.5)
        }
    }
    
    /// 현재 위치 버튼
    var currentLocationButton: some View {
        Button {
            
        } label: {
            ZStack {
                Asset.Images.currentLocationButton.swiftUIImage
                    .resizable()
                    .renderingMode(.template)
                    .tint(Asset.Colors.mainColor.swiftUIColor)
                    .frame(width: 26, height: 26)
            }
            .frame(width: 40, height: 40)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(radius: 2.5, x: 2.5, y: 2.5)
        }
    }
}

#Preview {
    let store = Store(initialState: MainReducer.State()) {
        MainReducer()
    }
    
    return MainView(store: store)
}
