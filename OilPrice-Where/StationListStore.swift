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
    
    @Dependency(\.stationClient) var stationClient
    
    struct State: Equatable {
        var isOrderByPrice: Bool = true
        var address: String = ""
        var stations: [GasStation] = []
    }
    
    enum Action: Equatable {
        case requestStations
        case requestAddress
        case updateStations([GasStation])
        case updateAddress(String)
        case orderByPrice
        case orderByDistance
        case favoriteButtonTapped(String)
    }
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .requestStations:
                return .run { [isOrderByPrice = state.isOrderByPrice] send in
                    do {
                        let stations = try await stationClient.requestStations(isOrderByPrice)
                        await send(.updateStations(stations))
                    } catch {
                        LogUtil.d(error.localizedDescription)
                    }
                }
            case .requestAddress:
                return .run { send in
                    do {
                        let address = try await stationClient.requestAddress()
                        await send(.updateAddress(address))
                    } catch {
                        LogUtil.d(error.localizedDescription)
                    }
                }
            case .updateStations(let stations):
                state.stations = stations
                return .none
            case .updateAddress(let address):
                state.address = address
                return .none
            case .orderByPrice:
                state.isOrderByPrice = true
                return .run { send in
                    await send(.requestStations)
                }
            case .orderByDistance:
                state.isOrderByPrice = false
                return .run { send in
                    await send(.requestStations)
                }
            case .favoriteButtonTapped(let id):
                favoriteButtonTapped(stationId: id)
                
                return .none
                
            }
        }
    }
}

extension StationListReducer {
    private func favoriteButtonTapped(stationId: String) {
        var favorites = DefaultData.shared.favoriteSubject.value
        let deleteIndex = favorites.firstIndex(where: { $0 == stationId })
        
        // 삭제
        if let deleteIndex {
            favorites.remove(at: deleteIndex)
            DefaultData.shared.favoriteSubject.send(favorites)
            return
        }
        
        // 추가
        guard favorites.count < 6 else {
            return
        }
        
        favorites.append(stationId)
        DefaultData.shared.favoriteSubject.send(favorites)
    }
}
