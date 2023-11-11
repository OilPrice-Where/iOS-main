//
//  OilBrand.swift
//  OilPrice-Where
//
//  Created by wargi on 11/13/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import Foundation
import SwiftUI

enum OilBrand: String, CaseIterable {
    case all = "ALL"
    /// SK에너지
    case sk = "SKE"
    /// 현대오일뱅크
    case hyundai = "HDO"
    /// GS칼텍스
    case gs = "GSC"
    /// S-OIL
    case sOil = "SOL"
    /// SK가스
    case skGas = "SKG"
    /// 자영 알뜰
    case selfThrifty = "RTO"
    /// E1
    case e1 = "E1G"
    /// 자가상표
    case selfBrand = "ETC"
    /// 농협알뜰
    case nh = "NHO"
    /// 고속도로알뜰
    case exOil = "RTX"
    
    var name: String {
        switch self {
        case .all:
            "모두"
        case .sk:
            "SK에너지"
        case .hyundai:
            "현대오일뱅크"
        case .gs:
            "GS칼텍스"
        case .sOil:
            "S-OIL"
        case .skGas:
            "SK가스"
        case .selfThrifty:
            "자영알뜰"
        case .e1:
            "E1"
        case .selfBrand:
            "자가상표"
        case .nh:
            "농협알뜰"
        case .exOil:
            "고속도로알뜰"
        }
    }
    
    var logo: Image? {
        switch self {
        case .all:
            nil
        case .sk:
            Asset.Images.logoSKEnergy.swiftUIImage
        case .hyundai:
            Asset.Images.logoOilBank.swiftUIImage
        case .gs:
            Asset.Images.logoGSCaltex.swiftUIImage
        case .sOil:
            Asset.Images.logoSOil.swiftUIImage
        case .skGas:
            Asset.Images.logoSKGas.swiftUIImage
        case .selfThrifty:
            Asset.Images.logoFrugalOil.swiftUIImage
        case .e1:
            Asset.Images.logoEnergyOne.swiftUIImage
        case .selfBrand:
            Asset.Images.logoPersonalOil.swiftUIImage
        case .nh:
            Asset.Images.logoNHOil.swiftUIImage
        case .exOil:
            Asset.Images.logoExpresswayOil.swiftUIImage
        }
    }
    
    static func brand(name: String?) -> OilBrand? {
        allCases.first(where: { $0.name == name })
    }
}

final class OilBrandModel: ObservableObject {
    var brand: OilBrand
    var isSelected: Bool
    
    init(oilBrand: OilBrand) {
        self.brand = oilBrand
        
        let selectedBrands = DefaultData.shared.brandsSubject.value
        let isAllSelected = selectedBrands.count == (OilBrand.allCases.count - 1)
        if oilBrand.rawValue == "ALL" {
            let isAllSelected = selectedBrands.count == (OilBrand.allCases.count - 1)
            self.isSelected = isAllSelected
        } else {
            self.isSelected = selectedBrands.contains(where: { $0 == oilBrand.rawValue })
        }
    }
    
    init(brand: OilBrand, isSelected: Bool) {
        self.brand = brand
        self.isSelected = isSelected
    }
}

extension OilBrandModel: Identifiable, Equatable {
    static func == (lhs: OilBrandModel, rhs: OilBrandModel) -> Bool {
        return lhs.brand.rawValue == rhs.brand.rawValue
    }
    
    var id: String {
        brand.rawValue
    }
}
