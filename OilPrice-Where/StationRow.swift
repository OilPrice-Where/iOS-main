//
//  StationRow.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI

struct StationRow: View {
    
    let station: GasStation
    
    var logoImage: Image = Asset.Images.logoSOil.swiftUIImage
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                if let logoImage: Image = Preferences.logoImage(name: station.brand) {
                    logoImage
                }
                
                Text(station.name)
                    .font(FontFamily.NanumSquareRound.bold.swiftUIFont(size: 18))
                Spacer()
            }
            .frame(height: 30)
                        
            HStack(alignment: .bottom) {
                Spacer()
                
                Text(Preferences.oil(code: DefaultData.shared.oilSubject.value))
                    .font(FontFamily.NanumSquareRound.bold.swiftUIFont(size: 14))
                    .foregroundStyle(.gray)
                    .padding(.bottom, 8)
                
                Text(Preferences.priceToWon(price: station.price))
                    .font(FontFamily.NanumSquareRound.extraBold.swiftUIFont(size: 32))
                    .padding(.leading, -4)
                
                Text("원")
                    .font(FontFamily.NanumSquareRound.extraBold.swiftUIFont(size: 14))
                    .padding(.leading, -4)
                    .padding(.bottom, 8)
            }
            
            HStack {
                Button(action: {
                    favoriteButtonTapped()
                }, label: {
                    Asset.Images.favoriteOffIcon.swiftUIImage
                        .renderingMode(.template)
                        .tint(Asset.Colors.mainColor.swiftUIColor)
                        .frame(width: 80, height: 40)
                        .overlay {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .foregroundStyle(Asset.Colors.mainColor.swiftUIColor)
                        }
                })
                
                Spacer(minLength: 16)
                
                Button(action: {
                    directionButtonTapped()
                }, label: {
                    HStack {
                        Asset.Images.findMapIcon.swiftUIImage
                            .renderingMode(.template)
                            .tint(.white)
                        
                        Text("\(Preferences.distance(km: station.distance)) 안내 시작")
                            .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 18))
                            .foregroundStyle(.white)
                    }
                    .frame(height: 40)
                    .frame(maxWidth: .infinity)
                    .background(Asset.Colors.mainColor.swiftUIColor)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                })
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .padding(.horizontal, 16)
        .frame(height: 168)
        .background(.white)
    }
    
    private func favoriteButtonTapped() {
        var favorites = DefaultData.shared.favoriteSubject.value
        let deleteIndex = favorites.firstIndex(where: { $0 == station.id })
        
        // 삭제
        if let deleteIndex {
            favorites.remove(at: deleteIndex)
            DefaultData.shared.favoriteSubject.send(favorites)
            return
        }
        
        // 추가
        guard favorites.count < 6 else {
            return
        }
        
        favorites.append(station.id)
        DefaultData.shared.favoriteSubject.send(favorites)
    }
    
    private func directionButtonTapped() {
        
    }
}

#Preview {
    StationRow(station: GasStation(
        id: "1",
        name: "(주)연우에너지 신관주유소",
        brand: "SKE",
        x: .zero,
        y: .zero
    ))
}
