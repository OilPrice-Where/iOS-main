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
    var stations: CurrentValueSubject<[GasStationSummary], Never>
    var isSortedByPrice = true
    
    //MARK: Initializer
    init(stations: [GasStationSummary]) {
        self.stations = CurrentValueSubject<[GasStationSummary], Never>(stations)
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
        let sortedStations = isPrice ? value.sorted(by: { $0.price < $1.price }) : value.sorted(by: { $0.distance < $1.distance })
        stations.send(sortedStations)
    }
}
