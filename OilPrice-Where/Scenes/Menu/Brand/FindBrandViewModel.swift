//
//  FindBrandViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import Combine
//MARK: FindBrandViewModel
final class FindBrandViewModel {
    var cancelBag = Set<AnyCancellable>()
    private let findBrand = [ // 선택 가능한 탐색 반경
        "전체",
        "SK에너지",
        "현대오일뱅크",
        "GS칼텍스",
        "S-OIL",
        "SK가스",
        "자영알뜰",
        "E1",
        "자가상표",
        "농협알뜰",
        "고속도로알뜰"
    ]
    
    let allBrands = ["SOL", "RTX", "ETC", "SKE", "GSC", "HDO", "RTO", "NHO", "E1G", "SKG"]
    
    var brandSubject: CurrentValueSubject<[String], Never>
    
    init() {
        self.brandSubject = CurrentValueSubject<[String], Never>(findBrand)
    }
}
