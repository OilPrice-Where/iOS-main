//
//  SupportHelper.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/11/14.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import SwiftUI

protocol SupportHelper {}

extension SupportHelper {
    func widthOfString(_ text: String?, usingFont: UIFont?) -> CGFloat {
        guard let text else { return .zero }
        let font = usingFont ?? .systemFont(ofSize: 8)
        
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = text.size(withAttributes: fontAttributes)
        return size.width + 10
    }
    
    func brand(code: String?) -> Color {
        guard let code else { return .gray }
        
        switch code {
        case "SKE":
            return .red
        case "GSC":
            return .orange
        case "HDO":
            return .blue
        case "SOL":
            return .green
        case "RTO":
            return .mint
        case "RTX":
            return .brown
        case "NHO":
            return .purple
        case "ETC":
            return .indigo
        case "E1G":
            return .pink
        case "SKG":
            return .red
        default:
            return .gray
        }
    }
    
    func brand(code: String?) -> String {
        guard let code else { return "전체" }
        
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
    
    func price(_ price: Int?, type: String?) -> String {
        guard let price, let type, price > 0 else { return "가격 정보 없음" }
        
        return "\(type) \(price)"
    }
}
