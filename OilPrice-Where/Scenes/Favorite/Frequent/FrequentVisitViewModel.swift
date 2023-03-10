//
//  FrequentVisitViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import UIKit
import Combine

//MARK: FrequentVisitViewModel
final class FrequentVisitViewModel {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let input = Input()
    let output = Output()
    
    //MARK: Initializer
    init() {
        bind()
    }
    
    //MARK: Binding..
    func bind() {
        DataManager.shared.stationListRelay
            .sink { [weak self] stations in
                guard let owner = self else { return }
                var dic = [String: Station]()
                
                stations.forEach {
                    if let id = $0.identifier {
                        if let _dic = dic[id] {
                            _dic.count += 1
                        } else {
                            let station = $0
                            station.count = 1
                            dic.updateValue(station, forKey: id)
                        }
                    }
                }
                
                let ret = dic.map { $0.value }.sorted(by: { $0.count > $1.count })
                owner.output.stations.send(ret)
            }
            .store(in: &cancelBag)
    }
}

//MARK: - I/O & Error
extension FrequentVisitViewModel {
    enum ErrorResult: Error {
        case someError
    }
    
    struct Input {
        
    }
    
    struct Output {
        var stations = CurrentValueSubject<[Station], Never>([])
    }
}

//MARK: - Method
extension FrequentVisitViewModel {
    
}
