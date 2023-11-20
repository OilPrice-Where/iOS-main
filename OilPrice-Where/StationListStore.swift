//
//  StationListStore.swift
//  OilPrice-Where
//
//  Created by wargi on 1/8/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import Foundation
import ComposableArchitecture


@Reducer
struct StationListReducer {
    struct State: Equatable {
        var isOrderByPrice: Bool = true
        var address: String = "서울특별시 강남구 역삼동 888-88번지"
        var stations: [GasStation] = [
            GasStation(
                id: "1",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            ),
            GasStation(
                id: "2",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            ),
            GasStation(
                id: "3",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            ),
            GasStation(
                id: "4",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            ),
            GasStation(
                id: "5",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            ),
            GasStation(
                id: "6",
                name: "(주)연우에너지 신관주유소",
                brand: "SKE",
                x: .zero,
                y: .zero
            )
        
        
        ]
    }
    
    enum Action: Equatable {
        case orderByPrice
        case orderByDistance
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .orderByPrice:
                state.isOrderByPrice = true
                return .none
            case .orderByDistance:
                state.isOrderByPrice = false
                return .none
            @unknown default:
                return .none
            }
        }
    }
}
