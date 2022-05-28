//
//  FrequentVisitViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import RxCocoa

//MARK: FrequentVisitViewModel
final class FrequentVisitViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
    let input = Input()
    let output = Output()
    
    //MARK: Initializer
    init() {
        rxBind()
    }
    
    //MARK: RxBinding..
    func rxBind() {
        DataManager.shared.stationListRelay
            .bind(with: self, onNext: { owner, _stations in
                var dic = [String: Station]()
                
                _stations.forEach {
                    if let id = $0.identifier {
                        if let _dic = dic[id] {
                            _dic.count += 1
                        } else {
                            dic.updateValue($0, forKey: id)
                        }
                    }
                }
                
                let ret = dic.map { $0.value }.sorted(by: { $0.count > $1.count })
                print(ret.count)
                owner.output.stations.accept(ret)
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
        var stations = BehaviorRelay<[Station]>(value: [])
    }
}

//MARK: - Method
extension FrequentVisitViewModel {
    
}
