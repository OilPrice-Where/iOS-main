//
//  LocationManager.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation
import Moya
import TMapSDK
import NMapsMap

final class LocationManager: NSObject {
    // MARK: - Properties
    static let shared = LocationManager()
    var locationManager: CLLocationManager?
    @Published var currentAddress: String?
    @Published var currentLocation: CLLocation?
    @Published var requestLocation: CLLocation?
    var findStations = [FindStation]()
    var stations = [GasStation]()
    let staionProvider = MoyaProvider<StationAPI>()
    var findStation: FindStation?
    
    // MARK: - Initializer
    private override init() {
        super.init()
        
        requestLocationAccess()
        TMapApi.setSKTMapAuthenticationWithDelegate(self, apiKey: "l7xx3d6e38a766c34c2dabd61f634263a2f6")
    }
    
    // MARK: - Functions
    // 위치 권한
    private func requestLocationAccess() {
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.allowsBackgroundLocationUpdates = true
        locationManager?.showsBackgroundLocationIndicator = true
        
        locationManager?.requestAlwaysAuthorization()
    }
    
    // 위치 추적 시작
    func startUpdating() {
        LogUtil.d("위치 추적 시작")
        locationManager?.startUpdatingLocation()
    }
    
    // 위치 추적 종료
    func stopUpdating() {
        LogUtil.d("위치 추적 종료")
        locationManager?.stopUpdatingLocation()
    }
    
    private func requestLocationAlert() {
        guard let visibleVC = UIApplication.shared.customKeyWindow?.visibleViewController else { return }
        
        let alert = UIAlertController(title: "위치정보를 불러올 수 없습니다.",
                                      message: "위치정보를 사용해 주변 '주유소'의 정보를 불러오기 때문에 위치정보 권한이 필요합니다. 설정으로 이동하여 위치 정보 접근을 허용해 주세요.",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        let openAction = UIAlertAction(title: "설정으로 이동",
                                       style: .default) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url,
                                          options: [:],
                                          completionHandler: nil)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        visibleVC.present(alert, animated: true, completion: nil)
    }
    
    func addressUpdate(location: CLLocation?, completion: @escaping (String?) -> ()) {
        guard let targetPoint = location?.coordinate else { return }
        
        let pathData = TMapPathData()
        
        pathData.reverseGeocoding(targetPoint, addressType: "A10") { result, error in
            if let result = result {
                LogUtil.d(result)
                
                if let city = result["city_do"] as? String,
                   let gu = result["gu_gun"] as? String,
                   let roadName = result["roadName"] as? String,
                   let buildingNumber = result["buildingIndex"] as? String {
                    completion("\(city) \(gu) \(roadName) \(buildingNumber)")
                }
            }
        }
    }
    
    func firstFindStation() -> FindStation? {
        guard let from = currentLocation else { return nil }
        
        return findStations.filter {
            guard let targetLat = $0.lat, let targetLng = $0.lng else { return false }
            let to = CLLocation(latitude: targetLat, longitude: targetLng)
            return from.distance(from: to) <= 2000
        }.first
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            LogUtil.d("GPS 권한 설정됨")
            self.locationManager?.startUpdatingLocation()
        case .notDetermined:
            LogUtil.d("GPS 권한 설정되지 않음")
            self.locationManager?.requestAlwaysAuthorization()
        case .restricted, .denied:
            LogUtil.d("GPS 권한 요청 거부됨")
            requestLocationAlert()
        default:
            break
        }
    }
    
    // 실패 했을경우 받은 알림
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        guard (error as NSError).code != CLError.locationUnknown.rawValue else {
            LogUtil.e("현재 위치 알 수 없음")
            return
        }
        
        switch manager.authorizationStatus {
        case .notDetermined:
            locationManager?.requestAlwaysAuthorization()
        case .restricted, .denied:
            requestLocationAlert()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
        
        if #available(iOS 16.1, *) {
            guard DefaultData.shared.backgroundFindSubject.value else { return }
            
            if let from = requestLocation, let to = locations.last,
               from.distance(from: to) > 3000 {
                requestLocation = to
                requestSearch()
            } else if requestLocation == nil {
                requestLocation = locations.last
                requestSearch()
            } else {
                self.findStation = firstFindStation()
                if var findStation = self.findStation,
                   let currentLocation = locations.last,
                   let targetLat = findStation.lat, let targetLng = findStation.lng {
                    let location = CLLocation(latitude: targetLat, longitude: targetLng)
                    findStation.distance = "\(Double(Int(currentLocation.distance(from: location) / 100)) / 10)km"
                    let state = StationAttributes.ContentState(station: findStation)
                    ActivityManager.shared.updateActivity(state: state)
                }
            }
        }
    }
}

extension LocationManager: TMapTapiDelegate {
    func SKTMapApikeySucceed() {
        LogUtil.d("APIKEY 인증 성공")
    }
}

extension LocationManager {
    @available(iOS 16.1, *)
    private func requestSearch(sort: Int = 1) {
        guard DefaultData.shared.backgroundFindSubject.value else { return }
        
        let oilSubject = DefaultData.shared.oilSubject.value
        let brands = DefaultData.shared.brandsSubject.value
        
        guard let targetLocation = requestLocation, let currentLocation else { return }
        
        let latLng = NMGLatLng(lat: targetLocation.coordinate.latitude, lng: targetLocation.coordinate.longitude)
        let tm = NMGTm128(from: latLng)
        
        staionProvider.request(.stationList(x: tm.x,
                                            y: tm.y,
                                            radius: 5000,
                                            prodcd: oilSubject,
                                            sort: sort,
                                            appKey: Preferences.getAppKey())) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                guard let list = try? response.map(OilList.self) else {
                    return
                }
                
                var target = list.result.gasStations.map { station -> GasStation in
                    let stationLatLng = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
                    let stationLocation = CLLocation(latitude: stationLatLng.lat, longitude: stationLatLng.lng)
                    let distanceValue = stationLocation.distance(from: currentLocation)
                    
                    return GasStation.init(id: station.id, brand: station.brand, name: station.name, price: station.price, distance: distanceValue, katecX: station.katecX, katecY: station.katecY)
                }
                
                if brands.count != 10 {
                    target = target.filter { brands.contains($0.brand) }
                }
                
                self.findStations = target.map { station -> FindStation in
                    let tm128 = NMGTm128(x: station.katecX, y: station.katecY)
                    let coordinate = tm128.toLatLng()
                    
                    return FindStation(id: station.id,
                                       name: station.name,
                                       brand: station.brand,
                                       oil: Preferences.oil(code: oilSubject),
                                       price: station.price,
                                       lat: coordinate.lat,
                                       lng: coordinate.lng,
                                       distance: "\(Double(Int(station.distance / 100)) / 10)km")
                }
                
                self.findStation = self.firstFindStation()
                let state = StationAttributes.ContentState(station: self.findStation)
                ActivityManager.shared.updateActivity(state: state)
                
                self.stations = list.result.gasStations
            case .failure(let error):
                LogUtil.e(error.localizedDescription)
            }
        }
    }
}
