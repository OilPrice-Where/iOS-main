//
//  MainListVC+MapKit.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import MapKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Foundation

//MARK: MapKit 관련
extension MainListViewController {
   // 마커 생성
   func showMarker() {
      guard let target = try? DefaultData.shared.stationsSubject.value() else { return }
      
      let stations = distanceSortButton.isSelected ? sortData : target
      
      annotations = stations.map {
         let katec = KatecPoint(x: $0.katecX, y: $0.katecY)
         let coordinate = Converter.convertKatecToWGS(katec: katec)
         
         return CustomMarkerAnnotation(coordinate: coordinate, info: $0)
      }
      
      appleMapView.addAnnotations(annotations)
   }
   
   // 화면 포커스
   func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
      let zoomRegion = MKCoordinateRegionMakeWithDistance(coordinate, 3000, 3000) // 2km, 2km
      appleMapView.setRegion(zoomRegion, animated: true)
   }
   
   // 맵의 현재위치 버튼
   @objc func currentLoaction(_ sender: UIButton) {
      zoomToLatestLocation(with: currentCoordinate!)
   }
   
   // 지도 보기
   @objc func viewMapAction(annotionIndex gesture: UITapGestureRecognizer) {
      guard let index = selectIndexPath?.section else { return }
      
      toList(self.toListButton)
      
      appleMapView.selectAnnotation(annotations[index], animated: true)
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
      
      var view = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? CustomMarkerAnnotationView
      if view == nil {
         view = CustomMarkerAnnotationView(annotation: annotation,
                                           reuseIdentifier: "imageAnnotation")
      }
      
      if let annotation = annotation as? CustomMarkerAnnotation {
         view?.annotation = annotation
         view?.stationInfo = annotation.stationInfo
         view?.priceLabel.text = "\(annotation.stationInfo.price)"
         view?.coordinate = annotation.coordinate
         view?.image = Preferences.logoImage(logoName: annotation.stationInfo.brand)
      }
      
      view?.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
      view?.priceLabel.textColor = .black
      
      if let lhs = view?.stationInfo?.price,
         let rhs = try? DefaultData.shared.stationsSubject.value().first?.price,
         lhs == rhs {
         view?.mapMarkerImageView.image = UIImage(named: "MinMapMarker")
         view?.priceLabel.textColor = UIColor.white
      }
      
      return view
   }
   
   // 마커 선택 Delegate
   func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
      guard let markerView = view as? CustomMarkerAnnotationView else { return } // MarkerView 확인
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
      
      currentPlacemark = MKPlacemark(coordinate: markerView.coordinate!)
      
      if let currentPlacemark = currentPlacemark {
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
      // 디테일 뷰 하단으로 변경
      detailView.detailViewBottomConstraint.constant = -150
      UIView.animate(withDuration: 0.3) {
         self.view.layoutIfNeeded()
      }
      appleMapView.removeOverlays(appleMapView.overlays) // 경로 선 삭제
      isSelectedAnnotion = false
      
      if let markerView = view as? CustomMarkerAnnotationView {
         markerView.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
         markerView.priceLabel.textColor = UIColor.black
         
         if let target = try? DefaultData.shared.stationsSubject.value().first?.price,
            let lhs = target, let rhs = markerView.stationInfo?.price, lhs == rhs {
               markerView.mapMarkerImageView.image = UIImage(named: "MinMapMarker")
               markerView.priceLabel.textColor = UIColor.white
         }
      }
   }
   
   
   // 경로관련 선 옵션 Delegate
   func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
      // 경로 선 옵션
      let renderer = MKPolylineRenderer(overlay: overlay)
      renderer.strokeColor = UIColor(named: "DarkMain")?.withAlphaComponent(0.8)
      renderer.lineWidth = 3.4
      
      return renderer
   }
}
