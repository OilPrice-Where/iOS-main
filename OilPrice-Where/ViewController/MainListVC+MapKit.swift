//
//  MainListVC+MapKit.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import MapKit
import Foundation

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

// MARK: - MKMapViewDelegate
extension MainListViewController: MKMapViewDelegate {
   // 마커 뷰 관련 설정 Delegate
   func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
      if annotation.isKind(of: MKUserLocation.self) {
         return nil
      }
      
      if !annotation.isKind(of: CustomMarkerAnnotation.self) {
         var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
         if pinAnnotationView == nil {
            pinAnnotationView = MKPinAnnotationView(annotation: annotation,
                                                    reuseIdentifier: "DefaultPinView")
         }
         return pinAnnotationView
      }
      
      var view: CustomMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? CustomMarkerAnnotationView
      if view == nil {
         view = CustomMarkerAnnotationView(annotation: annotation,
                                           reuseIdentifier: "imageAnnotation")
      }
      
      let annotation = annotation as! CustomMarkerAnnotation
      view?.annotation = annotation
      view?.stationInfo = annotation.stationInfo
      
      if view?.stationInfo?.price == DefaultData.shared.data![0].price {
         view?.mapMarkerImageView.image = UIImage(named: "MinMapMarker")
         view?.priceLabel.textColor = UIColor.white
      } else {
         view?.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
         view?.priceLabel.textColor = UIColor.black
      }
      
      if let stationInfo = annotation.stationInfo {
         view?.priceLabel.text = String(stationInfo.price)
         view?.coordinate = annotation.coordinate
         view?.image = Preferences.logoImage(logoName: stationInfo.brand)
      }
      
      return view
   }
   
   // 마커 선택 Delegate
   func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let markerView = view as? CustomMarkerAnnotationView else { return } // MarkerView 확인
      guard let stationInfo = markerView.stationInfo else { return } // 주유소 Data 확인
      
      // 선택된 주유소의 Katec 좌표 전달
      self.lastKactecX = stationInfo.katecX
      self.lastKactecY = stationInfo.katecY
      
      // 디테일 뷰 설정
      detailView.configure(stationInfo)
      detailView.detailViewTapGestureRecognizer(target: self, action: #selector(self.navigateStart(_:)))
      markerView.mapMarkerImageView.image = UIImage(named: "SelectMapMarker")
      markerView.priceLabel.textColor = UIColor.white
      
      // 마커 선택 시 디테일 뷰 애니메이션
      self.detailView.detailViewBottomConstraint.constant = 10
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
      
      self.currentPlacemark = MKPlacemark(coordinate: markerView.coordinate!)
      
      if let currentPlacemark = self.currentPlacemark {
         let directionRequest = MKDirectionsRequest()
         let destinationPlacemark = MKPlacemark(placemark: currentPlacemark)
         
         directionRequest.source = MKMapItem.forCurrentLocation()
         directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
         directionRequest.transportType = .automobile
         
         // 거리 계산 / 루트
         let directions = MKDirections(request: directionRequest)
         directions.calculate { (directionsResponse, err) in
            guard let directionsResponse = directionsResponse else {
               if let err = err {
                  print("Error directions: \(err.localizedDescription)")
               }
               return
            }
            
            let route = directionsResponse.routes[0] // 가장 빠른 루트
            self.appleMapView.removeOverlays(self.appleMapView.overlays) // 이전 경로 삭제
            self.appleMapView.add(route.polyline, level: .aboveRoads) // 경로 추가
         }
      }
      zoomToLatestLocation(with: markerView.coordinate!) // 마커 선택 시 마커 위치를 맵의 가운데로 표시
      isSelectedAnnotion = true
   }
   
   // 마커 선택해제 관련 Delegate
   func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
      let markerView = view as? CustomMarkerAnnotationView
      
      if markerView?.stationInfo?.price == DefaultData.shared.data![0].price {
         markerView?.mapMarkerImageView.image = UIImage(named: "MinMapMarker")
         markerView?.priceLabel.textColor = UIColor.white
      } else {
         markerView?.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
         markerView?.priceLabel.textColor = UIColor.black
      }
      
      // 디테일 뷰 하단으로 변경
      self.detailView.detailViewBottomConstraint.constant = -150
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
      self.appleMapView.removeOverlays(self.appleMapView.overlays) // 경로 선 삭제
      isSelectedAnnotion = false
   }
   
   
   // 경로관련 선 옵션 Delegate
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      // 경로 선 옵션
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = UIColor(named: "MainColor")?.withAlphaComponent(0.8)
      renderer.lineWidth = 5.0
      
      return renderer
   }
}
