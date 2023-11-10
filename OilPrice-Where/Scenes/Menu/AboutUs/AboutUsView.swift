//
//  AboutUsView.swift
//  OilPrice-Where
//
//  Created by wargi on 11/11/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import SwiftUI

struct AboutUsView: View {
    let models = AboutMe.allCases
    
    var body: some View {
        VStack {
            ZStack {
                Color(.main)
                Text("About Us")
                    .foregroundStyle(.white)
            }
            .frame(height: 44)
            
            ForEach(models, id: \.name) { model in
                Link(destination: URL(string: "https://www.\(model.link)")!) {
                    VStack(spacing: .zero) {
                        AboutCellView(model: model)
                        Color.gray
                            .frame(height: 0.5)
                            .padding(.leading, 20)
                    }
                    .foregroundStyle(.black)
                }
            }
            Spacer()
        }
    }
}

#Preview {
    AboutUsView()
}
