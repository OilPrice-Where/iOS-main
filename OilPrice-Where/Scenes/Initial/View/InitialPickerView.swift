//
//  InitialPickerView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI

struct InitialPickerView: View {
    var title: String
    var models: [String]
    @State var selected: String
    
    init(title: String, models: [String]) {
        self.title = title
        self.models = models
        self.selected = models.first ?? ""
        
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
        VStack {
            Text(title)
                .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 16))
                .foregroundStyle(Asset.Colors.mainColor.swiftUIColor)
                .padding(.bottom, 4)
            
            Picker("", selection: $selected) {
                ForEach(models, id: \.self) {
                    Text($0)
                }
            }
            .pickerStyle(.segmented)
        }
    }
}

#Preview {
    InitialPickerView(title: "찾으시는 기름의 종류를 선택해주세요.",
                      models: [
                        "휘발유", "경유", "고급유", "LPG"
                      ])
}
