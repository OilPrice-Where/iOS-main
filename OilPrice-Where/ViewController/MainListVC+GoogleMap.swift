//
//  MainListVC+GoogleMap.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/08/20.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import GoogleMaps
import TMapSDK

enum MapType: String {
   case appleMap = "AppleMap"
   case googleMap = "GoogleMap"
}

extension MapType {
   static func map(type: String) -> MapType {
      return type == "AppleMap" ? .appleMap : .googleMap
   }
}

extension MainListViewController: GMSMapViewDelegate {
   func deselectedMarker() {
      guard let marker = lastSelectedMarker else { return }
      // 디테일 뷰 하단으로 변경
      detailView.detailViewBottomConstraint.constant = -150
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
      isSelectedAnnotion = false
      
      if let markerView = marker.iconView as? CustomMarkerAnnotationView {
         markerView.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
         markerView.priceLabel.textColor = UIColor.black
         
         if let target = try? DefaultData.shared.stationsSubject.value().first?.price,
            let lhs = target, let rhs = markerView.stationInfo?.price, lhs == rhs {
            markerView.mapMarkerImageView.image = UIImage(named: "MinMapMarker")
            markerView.priceLabel.textColor = UIColor.white
         }
      }
      
      gMapView.selectedMarker = nil
      lastSelectedMarker = nil
   }
   
   func selectedMarker(at index: Int) {
      deselectedMarker()
      
      let marker = gMapMarkers[index]
      guard let markerView = marker.iconView as? CustomMarkerAnnotationView else { return } // MarkerView 확인
      guard let stationInfo = markerView.stationInfo else { return } // 주유소 Data 확인
      
      // 선택된 주유소의 Katec 좌표 전달
      lastKactecX = stationInfo.katecX
      lastKactecY = stationInfo.katecY
      
      // 디테일 뷰 설정
      detailView.configure(stationInfo)
      detailView.detailViewTapGestureRecognizer(target: self, action: #selector(navigateStart(_:)))
      markerView.mapMarkerImageView.image = UIImage(named: "SelectMapMarker")
      markerView.priceLabel.textColor = UIColor.white
      
      // 마커 선택 시 디테일 뷰 애니메이션
      detailView.detailViewBottomConstraint.constant = 10
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
      
      zoomToLatestLocation(with: markerView.coordinate) // 마커 선택 시 마커 위치를 맵의 가운데로 표시
      isSelectedAnnotion = true
      
      gMapView.selectedMarker = marker
      lastSelectedMarker = marker
   }
   
   func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
      guard let index = gMapMarkers.firstIndex(where: { marker == $0 }) else { return false }
      selectedMarker(at: index)
      
      return true
   }
   
   func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
      deselectedMarker()
   }
   
   func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
      guard let oldLocation = oldLocation else { return }
      
      let centerCoordinate = Converter.centerCoordinates(with: mapView)
      let newLocation = CLLocation(latitude: centerCoordinate.latitude,
                                     longitude: centerCoordinate.longitude)
      
      let distance = newLocation.distance(from: oldLocation)
      
      guard distance > 5000 else { return }
      
      researchButton.isHidden = false
   }
}
