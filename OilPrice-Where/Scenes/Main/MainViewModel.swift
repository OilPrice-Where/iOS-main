//
//  MainViewModel.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import CoreLocation
import Combine
import Moya
import NMapsMap
import FloatingPanel

import Firebase
//MARK: MainViewModel
final class MainViewModel {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let input = Input()
    let output = Output()
    let staionProvider = MoyaProvider<StationAPI>()
    var stations = [GasStation]() { didSet { output.staionResult.send(nil) } }
    var requestLocation: CLLocation? = nil { didSet { addressUpdate() } }
    var selectedStation: GasStation? = nil { didSet { output.selectedStation.send(nil) } }
    var addressString: String?
    var cameraPosition: NMFCameraPosition?
    var beforeNAfter: (before: FloatingPanelState, after: FloatingPanelState) = (.hidden, .hidden)
    var isLiveActivities: Bool = false
    
    //MARK: - Initializer
    init() {
        rxBind()
    }
    
    //MARK: - Rx Binding ..
    func rxBind() {        
        input.requestStaions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.requestSearch()
            }
            .store(in: &cancelBag)
        
        DefaultData.shared.completedRelay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key in
                guard let owner = self,
                      !(key == "Favorites" || key == "LocalFavorites") else {
                    return
                }
                
                owner.requestSearch()
            }
            .store(in: &cancelBag)
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
        let requestStaions = PassthroughSubject<Void?, Never>() // <= 검색
    }
    
    struct Output {
        let error = PassthroughSubject<ErrorResult, Never>() // => Error
        let staionResult = PassthroughSubject<Void?, Never>() // => 검색 결과
        let selectedStation = PassthroughSubject<Void?, Never>() // => 주유소 선택
        let deviceOrientation = PassthroughSubject<Void?, Never>() // => g
    }
}

//MARK: - Method
extension MainViewModel {
    private func addressUpdate() {
        guard let location = LocationManager.shared.currentLocation else { return }
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
        let oilSubject = DefaultData.shared.oilSubject.value
        let brands = DefaultData.shared.brandsSubject.value
        
        guard let coordinate = requestLocation?.coordinate else { return }
        
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let tm = NMGTm128(from: latLng)
        
        staionProvider.request(.stationList(x: tm.x,
                                            y: tm.y,
                                            radius: 5000,
                                            prodcd: oilSubject,
                                            sort: sort,
                                            appKey: Preferences.getAppKey())) { [weak self] result in
            guard let self = self,
                  let _currentLocation = LocationManager.shared.currentLocation else { return }
            switch result {
            case .success(let response):
                guard let list = try? response.map(OilList.self) else {
                    self.output.error.send(.stationList)
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
                LogUtil.e(error.localizedDescription)
                self.output.error.send(.requestStation)
            }
        }
    }
    
    func requestStationsInfo(id: String, completion: @escaping Completion) {
        staionProvider.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
            completion($0)
        }
    }
}
