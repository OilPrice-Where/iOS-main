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
    
    
    init() {
        rxBind()
    }
    
    func rxBind() {
        input.requestStaions
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
        let staionResult = PublishRelay<[GasStation]>() // => 검색 결과
    }
}

extension MainViewModel {
    private func requestSearch(sort: Int = 1) {
        guard let radius = try? DefaultData.shared.radiusSubject.value(),
              let oilSubject = try? DefaultData.shared.oilSubject.value(),
              let brands = try? DefaultData.shared.brandsSubject.value(),
              let coordinate = currentLocation?.coordinate else { return }
        
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let tm = NMGTm128(from: latLng)
        
        staionProvider.request(.stationList(x: tm.x, y: tm.y, radius: radius, prodcd: oilSubject, sort: sort, appKey: Preferences.getAppKey())) {
            switch $0 {
            case .success(let response):
                guard let list = try? response.map(OilList.self) else {
                    self.output.error.accept(.stationList)
                    return
                }
                
                var target = list.result.gasStations
                
                if brands.count != 10 {
                    target = target.filter { brands.contains($0.brand) }
                }
                
                self.output.staionResult.accept(target)
            case .failure(let error):
                print(error.localizedDescription)
                
                self.output.error.accept(.requestStation)
            }
        }
    }
}
