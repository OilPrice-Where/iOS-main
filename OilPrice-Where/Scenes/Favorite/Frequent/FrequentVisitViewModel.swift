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
import RxSwift
import RxCocoa

//MARK: FrequentVisitViewModel
final class FrequentVisitViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
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
            .bind(with: self, onNext: { owner, _stations in
                var dic = [String: Station]()
                
                _stations.forEach {
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
            })
            .disposed(by: bag)
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
