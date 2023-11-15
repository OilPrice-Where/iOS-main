//
//  NavigationPickerView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


struct NavigationPickerView: View {
    
    let store: StoreOf<InitialSettingReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("찾으시는 기름의 종류를 선택해주세요.")
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Asset.Colors.mainColor.swiftUIColor)
                    .padding(.bottom, 4)
                
                Picker("", selection: viewStore.binding(
                    get: { $0.navigationType },
                    send: InitialSettingReducer.Action.navigationTypeChanged
                )) {
                    ForEach(InitialSettingReducer.State.NavigationType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
