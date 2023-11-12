//
//  InitialSettingView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI

struct InitialSettingView: View {
    var body: some View {
        ZStack {
            Asset.Colors.mainColor.swiftUIColor
            VStack {
                oilTypePicker
                
                navigationPicker
                
                okButton
                
                Spacer()
            }
            .frame(height: 274)
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .padding(.horizontal, 16)
        }
        .ignoresSafeArea()
    }
}

//MARK: - Views...
extension InitialSettingView {
    var oilTypePicker: some View {
        InitialPickerView(
            title: "찾으시는 기름의 종류를 선택해주세요.",
            models: ["휘발유", "경유", "고급유", "LPG"]
        )
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
    
    var navigationPicker: some View {
        InitialPickerView(
            title: "연동할 내비게이션을 선택해주세요.",
            models: ["카카오내비", "카카오맵", "티맵", "네이버지도"]
        )
        .padding(.top, 24)
        .padding(.horizontal, 16)
    }
    
    var okButton: some View {
        Button {
            
        } label: {
            Text("확인")
                .foregroundStyle(.white)
                .frame(height: 40)
                .frame(maxWidth: .infinity)
                .background(Asset.Colors.mainColor.swiftUIColor)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.top, 24)
                .padding(.horizontal, 16)
        }
    }
}

#Preview {
    InitialSettingView()
}
