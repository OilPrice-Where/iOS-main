//
//  MainListViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//MARK: MainListViewModel
final class MainListViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
    var stations: [GasStation]
    var isSortedByPrice = true
    
    //MARK: Initializer
    init(stations: [GasStation]) {
        self.stations = stations
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
        isSortedByPrice = isPrice
        stations = isPrice ? stations.sorted(by: { $0.price < $1.price }) : stations.sorted(by: { $0.distance < $1.distance })
    }
}
