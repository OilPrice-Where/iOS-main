//
//  EditSalePriceViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

typealias BrandInfomation = (logo: UIImage?, title: String)

final class EditSalePriceViewModel {
    private let brandsInfo: [BrandInfomation] = [ // 선택 가능한 탐색 반경
        (UIImage(named: "LogoSKEnergy"), "SK"),
        (UIImage(named: "LogoOilBank"), "현대오일뱅크"),
        (UIImage(named: "LogoGSCaltex"), "GS칼텍스"),
        (UIImage(named: "LogoSOil"), "S-OIL"),
        (UIImage(named: "LogoEnergyOne"), "E1"),
        (UIImage(named: "LogoFrugalOil"), "알뜰주유소"),
        (UIImage(named: "LogoNHOil"), "농협")
    ]
    
    var brandsInfoSubject: BehaviorSubject<[BrandInfomation]>
    
    init() {
        self.brandsInfoSubject = BehaviorSubject<[BrandInfomation]>(value: brandsInfo)
    }
}
