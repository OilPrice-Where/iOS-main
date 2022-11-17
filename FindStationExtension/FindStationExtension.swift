//
//  FindStationExtension.swift
//  FindStationExtension
//
//  Created by wargi on 2022/11/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import SwiftUI
import WidgetKit
import ActivityKit
import CoreLocation

struct FindStationExtensionEntryView: View, SupportHelper {
    let context: ActivityViewContext<StationAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                .fill(.black)
            
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                            .fill(brand(code: context.state.station?.brand))
                        Text(brand(code: context.state.station?.brand))
                            .font(.custom("NanumSquareRoundEB", size: 10))
                            .foregroundColor(.white)
                    }
                    .frame(width: widthOfString(brand(code: context.state.station?.brand),
                                                usingFont: UIFont(name: "NanumSquareRoundEB", size: 10)),
                           height: 18)
                    
                    Text(price(context.state.station?.price, type: context.state.station?.oil))
                        .font(.custom("NanumSquareRoundEB", size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    HStack(spacing: 4.0) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 15, height: 15)
                        Text(context.state.station?.distance ?? "")
                            .foregroundColor(.white.opacity(0.6))
                            .font(.custom("NanumSquareRoundR", size: 16))
                    }
                }
                
                HStack(alignment: .bottom, spacing: 0) {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(context.state.station?.name ?? "")
                            .font(.custom("NanumSquareRoundB", size: 18))
                            .foregroundColor(.white.opacity(0.6))
                        Text("")
                            .font(.caption2)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            }
            .padding(15)
        }
    }
}

struct FindStationExtension: Widget, SupportHelper {
    let kind: String = "FindStationExtension"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: StationAttributes.self) { context in
            FindStationExtensionEntryView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Create the expanded presentation.
                DynamicIslandExpandedRegion(.leading) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                            .fill(brand(code: context.state.station?.brand))
                        Text(brand(code: context.state.station?.brand))
                            .font(.custom("NanumSquareRoundEB", size: 8))
                            .foregroundColor(.white)
                    }
                    .frame(width: widthOfString(brand(code: context.state.station?.brand),
                                                usingFont: UIFont(name: "NanumSquareRoundEB", size: 8)),
                           height: 16)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    HStack(alignment: .center, spacing: 4.0) {
                        Image(systemName: "location.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .foregroundColor(.white.opacity(0.6))
                            .frame(width: 14, height: 14)
                        Text(context.state.station?.distance ?? "")
                            .font(.custom("NanumSquareRoundR", size: 14))
                            .foregroundColor(.white.opacity(0.6))
                            .font(.body)
                    }
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.station?.name ?? "")
                            .font(.custom("NanumSquareRoundB", size: 14))
                            .foregroundColor(.white.opacity(0.6))
                        Spacer()
                        Text(price(context.state.station?.price, type: context.state.station?.oil))
                            .font(.custom("NanumSquareRoundEB", size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
            } compactTrailing: {
            } minimal: {
                ZStack {
                    Circle()
                        .fill(brand(code: context.state.station?.brand))
                    Text("\(context.state.station?.distance?.replacingOccurrences(of: "km", with: "") ?? "")")
                        .font(.custom("NanumSquareRoundEB", size: 12))
                        .foregroundColor(.white)
                }
            }
            .keylineTint(.indigo)
        }

    }
    

}
