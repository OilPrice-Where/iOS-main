//
//  MainViewModel.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import CoreLocation
import RxSwift
import RxCocoa
import Moya
import NMapsMap
import NSObject_Rx

final class MainViewModel {
    let input = Input()
    let output = Output()
    let staionProvider = MoyaProvider<StationAPI>()
    let bag = DisposeBag()
    var currentLocation: CLLocation? = nil
    var stations = [GasStation]() { didSet { output.staionResult.accept(()) } }
    
    init() {
        rxBind()
    }
    
    func rxBind() {
        input.requestStaions
            .bind(with: self, onNext: { owner, _ in
                owner.requestSearch()
            })
            .disposed(by: bag)
        
        DefaultData.shared.completedRelay
            .bind(with: self, onNext: { owner, _ in
                owner.requestSearch()
            })
            .disposed(by: bag)
    }
}

extension MainViewModel {
    enum ErrorResult: Error {
        case requestStation // => Network
        case reseponseStaion // => Response
        case stationList // => Favorite
    }
    
    struct Input {
        let requestStaions = PublishRelay<Void?>() // <= 검색
    }
    
    struct Output {
        let error = PublishRelay<ErrorResult>() // => Error
        let staionResult = PublishRelay<Void>() // => 검색 결과
    }
}

extension MainViewModel {
    private func requestSearch(sort: Int = 1) {
        let radius = DefaultData.shared.radiusSubject.value
        let oilSubject = DefaultData.shared.oilSubject.value
        let brands = DefaultData.shared.brandsSubject.value
        
        guard let coordinate = currentLocation?.coordinate else { return }
        
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let tm = NMGTm128(from: latLng)
        
        staionProvider.request(.stationList(x: tm.x,
                                            y: tm.y,
                                            radius: radius,
                                            prodcd: oilSubject,
                                            sort: sort,
                                            appKey: Preferences.getAppKey())) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let list = try? response.map(OilList.self) else {
                    self.output.error.accept(.stationList)
                    return
                }
                
                var target = list.result.gasStations
                
                if brands.count != 10 {
                    target = target.filter { brands.contains($0.brand) }
                }
                
                self.stations = target
            case .failure(let error):
                print(error.localizedDescription)
                self.output.error.accept(.requestStation)
            }
        }
    }
}
