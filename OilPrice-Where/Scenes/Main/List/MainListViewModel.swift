//
//  MainListViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine

//MARK: MainListViewModel
final class MainListViewModel {
    //MARK: - Properties
    var cancellable = Set<AnyCancellable>()
    var stations: CurrentValueSubject<[GasStationSummaryDTO], Never>
    var isSortedByPrice = true
    
    //MARK: Initializer
    init(stations: [GasStationSummaryDTO]) {
        self.stations = CurrentValueSubject<[GasStationSummaryDTO], Never>(stations)
    }
}

//MARK: - I/O & Error
extension MainListViewModel {
    enum ErrorResult: Error {
        case someError
    }
}

//MARK: - Method
extension MainListViewModel {
    func sortedList(isPrice: Bool) {
        let value = stations.value
        isSortedByPrice = isPrice
        let sortedStations = isPrice ? value.sorted(by: { $0.price ?? .zero < $1.price ?? .zero }) : value.sorted(by: { $0.distance ?? .zero < $1.distance ?? .zero })
        stations.send(sortedStations)
    }
}
