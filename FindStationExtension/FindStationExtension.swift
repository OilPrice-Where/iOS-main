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

struct FindStationExtensionEntryView : View {
    let context: ActivityViewContext<StationAttributes>
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                .fill(.black)
            
            VStack {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 15.0, style: .continuous)
                            .fill(.indigo)
                        Text(brand(code: context.state.station?.brand ?? ""))
                            .font(.custom("NanumSquareRoundEB", size: 10))
                            .foregroundColor(.white)
                    }
                    .frame(width: 50, height: 18)
                    
                    Text("\(context.state.station?.oil ?? "") \(context.state.station?.price ?? 0)")
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
    
    func brand(code: String) -> String {
        switch code {
        case "SKE":
            return "SK에너지"
        case "GSC":
            return "GS칼텍스"
        case "HDO":
            return "현대오일뱅크"
        case "SOL":
            return "S-OIL"
        case "RTO":
            return "자영알뜰"
        case "RTX":
            return "고속도로알뜰"
        case "NHO":
            return "농협알뜰"
        case "ETC":
            return "자가상표"
        case "E1G":
            return "E1"
        case "SKG":
            return "SK가스"
        default:
            return "전체"
        }
    }
}

struct FindStationExtension: Widget {
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
                            .fill(.indigo)
                        Text(brand(code: context.state.station?.brand ?? ""))
                            .font(.custom("NanumSquareRoundEB", size: 8))
                            .foregroundColor(.white)
                    }
                    .frame(width: 40, height: 16)
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
                        Text("\(context.state.station?.oil ?? "") \(context.state.station?.price ?? 0)")
                            .font(.custom("NanumSquareRoundEB", size: 16))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } compactLeading: {
            } compactTrailing: {
            } minimal: {
                Text("\(context.state.station?.distance?.replacingOccurrences(of: "km", with: "") ?? "")")
                    .font(.custom("NanumSquareRoundEB", size: 16))
                    .foregroundColor(.white)
            }
            .keylineTint(.indigo)
        }

    }
    
    func logoImage(logoName name: String?) -> Image {
        guard let logoName = name else { return Image(systemName: "drop.fill") }
        switch logoName {
        case "SKE":
            return Image("LogoSKEnergy")
        case "GSC":
            return Image("LogoGSCaltex")
        case "HDO":
            return Image("LogoOilBank")
        case "SOL":
            return Image("LogoSOil")
        case "RTO":
            return Image("LogoFrugalOil")
        case "RTX":
            return Image("LogoExpresswayOil")
        case "NHO":
            return Image("LogoNHOil")
        case "ETC":
            return Image("LogoPersonalOil")
        case "E1G":
            return Image("LogoEnergyOne")
        case "SKG":
            return Image("LogoSKGas")
        default:
            return Image(systemName: "drop.fill")
        }
    }
    
    func brand(code: String) -> String {
        switch code {
        case "SKE":
            return "SK에너지"
        case "GSC":
            return "GS칼텍스"
        case "HDO":
            return "현대오일뱅크"
        case "SOL":
            return "S-OIL"
        case "RTO":
            return "자영알뜰"
        case "RTX":
            return "고속도로알뜰"
        case "NHO":
            return "농협알뜰"
        case "ETC":
            return "자가상표"
        case "E1G":
            return "E1"
        case "SKG":
            return "SK가스"
        default:
            return "전체"
        }
    }
}
