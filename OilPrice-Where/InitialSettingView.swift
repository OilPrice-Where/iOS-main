//
//  InitialSettingView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture

struct InitialSettingView: View {
    let store: StoreOf<InitialSettingReducer>
    
    var body: some View {
        WithViewStore(self.store, observe: { $0 }) { viewStore in
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
}

//MARK: - Views...
extension InitialSettingView {
    var oilTypePicker: some View {
        OilTypePickerView(store: store)
            .padding(.top, 24)
            .padding(.horizontal, 16)
    }
    
    var navigationPicker: some View {
        NavigationPickerView(store: store)
            .padding(.top, 24)
            .padding(.horizontal, 16)
    }
    
    var okButton: some View {
        Button {
            store.send(.okButtonTapped)
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

struct InitialSettingView_Previews: PreviewProvider {
    static var previews: some View {
        let store = Store(initialState: InitialSettingReducer.State()) {
            InitialSettingReducer()
        }
        
        InitialSettingView(store: store)
    }
}

