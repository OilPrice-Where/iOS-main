//
//  OilBrandStore.swift
//  OilPrice-Where
//
//  Created by wargi on 11/13/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import ComposableArchitecture
import SwiftUI

class OilBrandReducer: Reducer {
    struct State: Equatable {
        var brands = [OilBrandModel]()
    }
    
    enum Action: Equatable {
        case fetchBrand
        case toggle(OilBrandModel)
    }
    
    func reduce(into state: inout State, action: Action) -> Effect<Action> {
        switch action {
        case .fetchBrand:
            let currentSelectedBrands = DefaultData.shared.brandsSubject.value
            let isAllSelected = currentSelectedBrands.count == (OilBrand.allCases.count - 1)
            
            state.brands.forEach {
                $0.isSelected = $0.brand == .all ? isAllSelected : currentSelectedBrands.contains($0.brand.rawValue)
            }
            return .none
        case .toggle(let model):
            var selectedBrands = DefaultData.shared.brandsSubject.value
            
            if model.brand == .all {
                let allBrands = OilBrand.allCases
                    .map { $0.rawValue }
                    .filter { $0 != "ALL" }
                selectedBrands = !model.isSelected ? allBrands : []
            } else {
                if let removeIndex = selectedBrands.firstIndex(where: { $0 == model.brand.rawValue }) {
                    selectedBrands.remove(at: removeIndex)
                } else {
                    selectedBrands.append(model.brand.rawValue)
                }
            }
            
            let isAllSelected = selectedBrands.count == (OilBrand.allCases.count - 1)
            
            state.brands.forEach {
                $0.isSelected = $0.brand == .all ? isAllSelected : selectedBrands.contains($0.brand.rawValue)
            }
            
            DefaultData.shared.brandsSubject.send(selectedBrands)
            
            return .run { send in
                await send(.fetchBrand)
            }
        }
    }
}
