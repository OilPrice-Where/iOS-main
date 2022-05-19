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
import FloatingPanel

import Firebase
//MARK: MainViewModel
final class MainViewModel {
    //MARK: - Properties
    let bag = DisposeBag()
    let input = Input()
    let output = Output()
    let staionProvider = MoyaProvider<StationAPI>()
    var stations = [GasStation]() { didSet { output.staionResult.accept(()) } }
    var currentLocation: CLLocation? = nil
    var requestLocation: CLLocation? = nil { didSet { addressUpdate() } }
    var selectedStation: GasStation? = nil { didSet { output.selectedStation.accept(()) } }
    var addressString: String?
    var cameraPosition: NMFCameraPosition?
    var beforeNAfter: (before: FloatingPanelState, after: FloatingPanelState) = (.hidden, .hidden)
    
    //MARK: - Initializer
    init() {
        rxBind()
    }
    
    //MARK: - Rx Binding ..
    func rxBind() {
        input.requestStaions
            .bind(with: self, onNext: { owner, _ in
                owner.requestSearch()
            })
            .disposed(by: bag)
        
        DefaultData.shared.completedRelay
            .bind(with: self, onNext: { owner, key in
                guard !(key == "Favorites" || key == "LocalFavorites") else {
                    return
                }
                
                owner.requestSearch()
            })
            .disposed(by: bag)
    }
}

//MARK: - I/O & Error
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
        let selectedStation = PublishRelay<Void>() // => 주유소 선택
        let deviceOrientation = PublishRelay<Void>() // => g
    }
}

//MARK: - Method
extension MainViewModel {
    private func addressUpdate() {
        guard let location = currentLocation else { return }
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { [weak self] placemarks, error in
            if let _ = error { return }
            
            var currentPlacemark: CLPlacemark?
            // 에러가 없고, 주소 정보가 있으며 주소가 공백이지 않을 시
            if error == nil, let p = placemarks, !p.isEmpty {
                currentPlacemark = p.last
            } else {
                currentPlacemark = nil
            }
            
            var string = currentPlacemark?.locality ?? ""
            string += string.count > 0 ? " " + (currentPlacemark?.name ?? "") : currentPlacemark?.name ?? ""
            self?.addressString = string
        }
    }
    
    private func requestSearch(sort: Int = 1) {
        let radius = DefaultData.shared.radiusSubject.value
        let oilSubject = DefaultData.shared.oilSubject.value
        let brands = DefaultData.shared.brandsSubject.value
        
        guard let coordinate = requestLocation?.coordinate else { return }
        
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let tm = NMGTm128(from: latLng)
        
        staionProvider.request(.stationList(x: tm.x,
                                            y: tm.y,
                                            radius: radius,
                                            prodcd: oilSubject,
                                            sort: sort,
                                            appKey: Preferences.getAppKey())) { [weak self] result in
            guard let self = self,
                  let _currentLocation = self.currentLocation else { return }
            switch result {
            case .success(let response):
                guard let list = try? response.map(OilList.self) else {
                    self.output.error.accept(.stationList)
                    return
                }
                
                var target = list.result.gasStations.map { station -> GasStation in
                    let stationLatLng = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
                    let stationLocation = CLLocation(latitude: stationLatLng.lat, longitude: stationLatLng.lng)
                    let distanceValue = stationLocation.distance(from: _currentLocation)
                    
                    return GasStation.init(id: station.id, brand: station.brand, name: station.name, price: station.price, distance: distanceValue, katecX: station.katecX, katecY: station.katecY)
                }
                
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
    
    func requestStationsInfo(id: String, completion: @escaping Completion) {
        staionProvider.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
            completion($0)
        }
    }
}
