//
//  StationBrand.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit


enum StationBrand: String, CaseIterable, Hashable {
    /// SK에너지
    case ske = "SKE"
    /// 현대오일뱅크
    case hdo = "HDO"
    /// GS칼텍스
    case gsc = "GSC"
    /// S-OIL
    case sol = "SOL"
    /// SK가스
    case skg = "SKG"
    /// 자영알뜰
    case rto = "RTO"
    /// 고속도로알뜰
    case rtx = "RTX"
    /// 농협알뜰
    case nho = "NHO"
    /// 자가상표
    case etc = "ETC"
    /// E1
    case e1g = "E1G"
    /// 전체 브랜드
    case all = "ALL"
    
    
    /// 브랜드 코드로 인스턴스 생성
    init(code: String) {
        self = StationBrand(rawValue: code.uppercased()) ?? .etc
    }
    
    /// 브랜드명으로 인스턴스 생성
    init(name: String) {
        self = StationBrand.allCases.first(where: { $0.name == name }) ?? .etc
    }
}

extension StationBrand {
    /// 각 브랜드에 해당하는 코드 반환
    var code: String {
        self.rawValue
    }
    
    /// 각 브랜드에 해당하는 이름 반환
    var name: String {
        switch self {
        case .ske:
            return "SK에너지"
        case .hdo:
            return "현대오일뱅크"
        case .gsc:
            return "GS칼텍스"
        case .sol:
            return "S-OIL"
        case .skg:
            return "SK가스"
        case .rto:
            return "자영알뜰"
        case .rtx:
            return "고속도로알뜰"
        case .nho:
            return "농협알뜰"
        case .etc:
            return "자가상표"
        case .e1g:
            return "E1"
        case .all:
            return "전체"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .ske:
            return Asset.Images.logoSKEnergy.image
        case .gsc:
            return Asset.Images.logoGSCaltex.image
        case .hdo:
            return Asset.Images.logoOilBank.image
        case .sol:
            return Asset.Images.logoSOil.image
        case .rto:
            return Asset.Images.logoFrugalOil.image
        case .rtx:
            return Asset.Images.logoExpresswayOil.image
        case .nho:
            return Asset.Images.logoNHOil.image
        case .etc:
            return Asset.Images.logoPersonalOil.image
        case .e1g:
            return Asset.Images.logoEnergyOne.image
        case .skg:
            return Asset.Images.logoSKGas.image
        case .all:
            return nil
        }
    }
}
