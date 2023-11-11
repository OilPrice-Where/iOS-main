//
//  OilBrandCellView.swift
//  OilPrice-Where
//
//  Created by wargi on 11/13/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import SwiftUI

struct OilBrandCellView: View {
    var model: OilBrand
    @Binding var toggleOn: Bool
    var onChanged: (OilBrandModel) -> ()
    
    var body: some View {
        Toggle(model.name, isOn: $toggleOn)
            .onChange(of: toggleOn) { value in
                onChanged(OilBrandModel(brand: model, isSelected: value))
            }
            .toggleStyle(SwitchToggleStyle(tint: Color(.main)))
            .padding(.horizontal, 20)
    }
}
