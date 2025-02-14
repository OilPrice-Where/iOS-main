//
//  LocationManager.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CoreLocation
import Then


final class LocationManager: NSObject {
    // MARK: - Properties
    static let shared = LocationManager()
    
    private var searchPathRepository: SearchPathRepository!
    
    private let locationManager = CLLocationManager().then {
        $0.desiredAccuracy = kCLLocationAccuracyBest
        $0.allowsBackgroundLocationUpdates = true
        $0.showsBackgroundLocationIndicator = true
        $0.distanceFilter = 50
        $0.requestAlwaysAuthorization()
    }
    @Published var currentAddress: String?
    @Published var currentLocation: CLLocation?
    @Published var requestLocation: CLLocation?
    
    var stations = [GasStationSummary]()
    
    // MARK: - Initializer
    private override init() {
        super.init()
        
        requestLocationAccess()
    }
    
    func setLocationManager(searchPathRepository: SearchPathRepository) {
        self.searchPathRepository = searchPathRepository
    }
}


// MARK: - Functions
extension LocationManager {
    /// 위치 권한
    private func requestLocationAccess() {
        locationManager.delegate = self
    }
    
    /// 위치 추적 시작
    func startUpdating() {
        LogUtil.d("위치 추적 시작")
        locationManager.startUpdatingLocation()
    }
    
    /// 위치 추적 종료
    func stopUpdating() {
        LogUtil.d("위치 추적 종료")
        locationManager.stopUpdatingLocation()
    }
    
    private func requestLocationAlert() {
        guard let visibleVC = UIApplication.shared.customKeyWindow?.visibleViewController else { return }
        
        let alert = UIAlertController(
            title: "위치정보를 불러올 수 없습니다.",
            message: "위치정보를 사용해 주변 '주유소'의 정보를 불러오기 때문에 위치정보 권한이 필요합니다. 설정으로 이동하여 위치 정보 접근을 허용해 주세요.",
            preferredStyle: .alert)
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel,
            handler: nil)
        let openAction = UIAlertAction(
            title: "설정으로 이동",
            style: .default
        ) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        visibleVC.present(alert, animated: true, completion: nil)
    }
    
    func addressUpdate() async -> String {
        guard let currentLocation else {
            return ""
        }
        
        let fullAddress = await searchPathRepository.reverseGeocoding(
            coordinate: CoordinateSystem(
                lat: currentLocation.coordinate.latitude,
                lng: currentLocation.coordinate.longitude
            )
        )
        
        return fullAddress
    }
    
    func fetchSearchPOIs(keyword: String?, count: Int = 30) async -> [SearchPOI] {
        guard let keyword, keyword.isNotEmpty else {
            return []
        }
        return await searchPathRepository.requestFindAllPOIs(keyword: keyword, count: count)
    }
    
    func distance(from: CoordinateSystem) -> CGFloat? {
        guard let to = currentLocation else {
            return nil
        }
        return to.distance(from: from.location)
    }
}


// MARK: - CLLocationManagerDelegate
extension LocationManager: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            LogUtil.d("GPS 권한 설정됨")
            self.locationManager.startUpdatingLocation()
        case .notDetermined:
            LogUtil.d("GPS 권한 설정되지 않음")
            self.locationManager.requestAlwaysAuthorization()
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
            locationManager.requestAlwaysAuthorization()
        case .restricted, .denied:
            requestLocationAlert()
        default:
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last
    }
}
