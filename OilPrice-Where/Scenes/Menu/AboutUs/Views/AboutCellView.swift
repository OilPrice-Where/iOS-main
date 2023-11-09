//
//  AboutCellView.swift
//  OilPrice-Where
//
//  Created by wargi on 11/12/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import SwiftUI

struct AboutCellView: View {
    var model: AboutMe
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("iOS Developer")
                    .font(FontFamily.NanumSquareRound.regular.swiftUIFont(size: 18))
                    .frame(height: 20)
                Text(model.name)
                    .font(FontFamily.NanumSquareRound.bold.swiftUIFont(size: 17))
                    .frame(height: 20)
                HStack(spacing: 3) {
                    Image(.github)
                        .resizable()
                        .frame(width: 22.5, height: 22.5)
                    Text(model.link)
                        .font(FontFamily.NanumSquareRound.light.swiftUIFont(size: 16))
                        .frame(height: 20)
                }
            }
            Spacer()
        }
        .padding(.horizontal, 20)
        .frame(height: 117)
    }
}

#Preview {
    AboutCellView(model: .wargi)
}
