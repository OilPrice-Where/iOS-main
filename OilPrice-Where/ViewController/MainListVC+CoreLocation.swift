//
//  MainListVC+CoreLocation.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import CoreLocation


// CoreLocation 관련 함수
extension MainListViewController {
   // 위치 관련 인증 확인
   @objc func configureLocationServices() {
      locationManager.delegate = self
      appleMapView.delegate = self
      
      let status = CLLocationManager.authorizationStatus() // 현재 인증상태 확인
      if status == .notDetermined { // notDetermined일 시 AlwaysAuthorization 요청
         locationManager.requestWhenInUseAuthorization()
         startLocationUpdates(locationManager: locationManager)
      } else if status == .authorizedAlways || status == .authorizedWhenInUse { // 인증시 위치 정보 받아오기 시작
         startLocationUpdates(locationManager: locationManager)
      } else if status == .restricted || status == .denied {
         let alert = UIAlertController(title: "위치정보를 불러올 수 없습니다.",
                                       message: "위치정보를 사용해 주변 주유소의 정보를 불러오기 때문에 위치정보 사용이 꼭 필요합니다. 설정으로 이동하여 위치 정보 접근을 허용해 주세요.",
                                       preferredStyle: .alert)
         let cancelAction = UIAlertAction(title: "취소",
                                          style: .cancel,
                                          handler: nil)
         
         let openAction = UIAlertAction(title: "설정으로 이동",
                                        style: .default) { (action) in
                                          if let url = URL(string: UIApplicationOpenSettingsURLString) {
                                             UIApplication.shared.open(url,
                                                                       options: [String : Any](), completionHandler: nil)
                                          }
         }
         
         alert.addAction(cancelAction)
         alert.addAction(openAction)
         
         self.present(alert, animated: true, completion: nil)
      }
   }
   
   // 위치 요청 시작
   func startLocationUpdates(locationManager: CLLocationManager) {
      appleMapView.showsUserLocation = true
      locationManager.desiredAccuracy = kCLLocationAccuracyBest
      locationManager.startUpdatingLocation()
   }
   
   // 위치 검색 중지
   func stopLocationManager() {
      locationManager.stopUpdatingLocation()
      locationManager.delegate = nil
   }
   
   // 주소 설정
   func string(from placemark: CLPlacemark?) -> String? {
      guard let currentPlacemark = placemark else {
         return nil
      }
      // address
      var address = ""
      if let s = currentPlacemark.administrativeArea {
         address += s + " "
      }
      if let s = currentPlacemark.locality {
         address += s + " "
      }
      if let s = currentPlacemark.thoroughfare {
         address += s
      }
      return address
   }
}

// MARK: - CLLocationManagerDelegate
extension MainListViewController: CLLocationManagerDelegate {
   func locationManager(_ manager: CLLocationManager, // 위치 관리자가 위치를 얻을 수 없을 때
      didFailWithError error: Error) {
      print("did Fail With Error \(error)")
      
      // CLError.locationUnknown: 현재 위치를 알 수 없는데 Core Location이 계속 위치 정보를 요청할 때
      // CLError.denied: 사용자가 위치 서비스를 사용하기 위한 앱 권한을 거부
      // CLError.network: 네트워크 관련 오류
      if (error as NSError).code == CLError.locationUnknown.rawValue {
         return
      }
      
      // CLError.locationUnknown의 오류 보다 더 심각한 오류가 발생하였을 때
      // lastLocationError에 오류를 저장한다.
      lastLocationError = error
      stopLocationManager()
   }
   
   func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
      let newLocation = locations.last
      
      if newLocation != nil {
         currentCoordinate = newLocation!.coordinate
         
         let katecPoint = Converter.convertWGS84ToKatec(coordinate: newLocation!.coordinate)
         
         if !performingReverseGeocoding {
            performingReverseGeocoding = true
            geocoder.reverseGeocodeLocation(newLocation!, completionHandler: {
               placemarks, error in
               self.lastGeocodingError = error
               // 에러가 없고, 주소 정보가 있으며 주소가 공백이지 않을 시
               if error == nil, let p = placemarks, !p.isEmpty {
                  self.currentPlacemark = p.last!
               } else {
                  self.currentPlacemark = nil
               }
               
               self.performingReverseGeocoding = false
               self.headerView.configure(with: self.string(from: self.currentPlacemark))
            })
         }
         if let lastLocation = oldLocation {
            let distance: CLLocationDistance = newLocation!.distance(from: lastLocation)
            if distance < 50.0 {
               stopLocationManager()
               self.tableView.reloadData()
            } else {
               reset()
               gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
               stopLocationManager()
               oldLocation = newLocation
               zoomToLatestLocation(with: currentCoordinate!)
            }
         } else {
            zoomToLatestLocation(with: currentCoordinate!)
            gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
            stopLocationManager()
            oldLocation = newLocation
         }
      }
      
      // 인증 상태가 변경 되었을 때
      func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
         if status == .authorizedAlways || status == .authorizedWhenInUse {
            startLocationUpdates(locationManager: manager)
         }
      }
   }
}
