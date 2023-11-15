//
//  OilTypePickerView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture


struct OilTypePickerView: View {
    
    let store: StoreOf<InitialSettingReducer>
    
    init(store: StoreOf<InitialSettingReducer>) {
        self.store = store
        
        UISegmentedControl.appearance().selectedSegmentTintColor = Asset.Colors.mainColor.color
        
        let font = FontFamily.NanumSquareRound.regular.font(size: 14)
        
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                              .foregroundColor: UIColor.black]
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                                .foregroundColor: UIColor.white]
        
        UISegmentedControl.appearance().setTitleTextAttributes(normalAttribute, for: .normal)
        UISegmentedControl.appearance().setTitleTextAttributes(selectedAttribute, for: .selected)
    }
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
            VStack {
                Text("찾으시는 기름의 종류를 선택해주세요.")
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16))
                    .foregroundStyle(Asset.Colors.mainColor.swiftUIColor)
                    .padding(.bottom, 4)
                
                Picker("", selection: viewStore.binding(
                    get: { $0.oilType },
                    send: InitialSettingReducer.Action.oilTypeChanged
                )) {
                    ForEach(InitialSettingReducer.State.OilType.allCases, id: \.self) {
                        Text($0.rawValue)
                    }
                }
                .pickerStyle(.segmented)
            }
        }
    }
}
