//
//  MainView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import Foundation
import SwiftUI


struct MainView: View {
    var body: some View {
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
    
    /// SideMenu 이동 버튼
    var sideMenuButton: some View {
        Button {
            
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
        Button {
            
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
        Button {
            
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
        Button {
            
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
        }
    }
}


struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
