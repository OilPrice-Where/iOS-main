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
    var cancelBag = Set<AnyCancellable>()
    var stations: CurrentValueSubject<[GasStation], Never>
    var isSortedByPrice = true
    
    //MARK: Initializer
    init(stations: [GasStation]) {
        self.stations = CurrentValueSubject<[GasStation], Never>(stations)
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
