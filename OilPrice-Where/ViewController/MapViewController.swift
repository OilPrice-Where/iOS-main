//
//  MapViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {

    var gasStations: [GasStation] = []
    
    //Detail View
    @IBOutlet private weak var logoType : UIImageView!
    @IBOutlet private weak var stationName : UILabel!
    @IBOutlet private weak var distance : UILabel!
    @IBOutlet private weak var oilPrice : UILabel!
    private var lastKactecX: Double?
    private var lastKactecY: Double?
    
    //Core Location
    var locationManager = CLLocationManager()
    var lastLocationError: Error?
    
    //Map Kit
    @IBOutlet private weak var mapView: MKMapView!
    private var currentCoordinate: CLLocationCoordinate2D?
    var currentPlacemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadData() // 지도위 데이터 로드
        configureLocationServices() // 로케이션 서바스 시작
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showMarker() // 마커 생성
    }
    
    // 지도위 데이터 정보 생성
    func loadData() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "gasStation"),
                                               object: nil,
                                               queue: nil) {
                                                [weak self] (noti) in
                                                if let gs = noti.object as? [GasStation] {
                                                    self?.gasStations = gs
                                                }
        }
        
        mapView.delegate = self
    }
    
    // 마커 생성
    func showMarker() {
        var annotations: [ImageAnnotation] = [] // 마커 배열 생성
        
        for i in 0..<gasStations.count {
            annotations.append(ImageAnnotation()) // 마커 생성
            annotations[i].coordinate = convertKatecToWGS(x: gasStations[i].katecX, // 마커 위치 선점
                                                          y: gasStations[i].katecY)
            annotations[i].image = logoImage(logoName: gasStations[i].brand) // 브랜드
            annotations[i].name = gasStations[i].name // 상호명
            annotations[i].distance = gasStations[i].distance // 거리
            annotations[i].price = gasStations[i].price // 가격
            annotations[i].katecX = gasStations[i].katecX // KatecX
            annotations[i].katecY = gasStations[i].katecY // KatecY
            self.mapView.addAnnotation(annotations[i]) // 맵뷰에 마커 생성
        }
    }
    
    // 로고 이미지
    func logoImage(logoName name: String) -> UIImage? {
        switch name {
        case "SKE":
            return UIImage(named: "LogoSKEnergy")
        case "GSC":
            return UIImage(named: "LogoGSCaltex")
        case "HDO":
            return UIImage(named: "LogoOilBank")
        case "SOL":
            return UIImage(named: "LogoSOil")
        case "RTO":
            return UIImage(named: "LogoFrugalOil")
        case "RTX":
            return UIImage(named: "LogoExpresswayOil")
        case "NHO":
            return UIImage(named: "LogoNHOil")
        case "ETC":
            return UIImage(named: "LogoPersonalOil")
        case "E1G":
            return UIImage(named: "LogoEnergyOne")
        case "SKG":
            return UIImage(named: "LogoSKGas")
        default:
            return nil
        }
    }
    
    // 위치 변환
    func convertKatecToWGS(x: Double, y: Double) -> CLLocationCoordinate2D {
        let convert = GeoConverter()
        let katecPoint = GeographicPoint(x: x, y: y)
        let wgsPoint = convert.convert(sourceType: .KATEC,
                                       destinationType: .WGS_84,
                                       geoPoint: katecPoint)
        
        return CLLocationCoordinate2D(latitude: wgsPoint!.y.roundTo(places: 6),
                                      longitude: wgsPoint!.x.roundTo(places: 6))
        
    }
    
    // 위치 관련 인증 확인
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus() // 현재 인증상태 확인
        
        if status == .notDetermined { // notDetermined일 시 AlwaysAuthorization 요청
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse { // 인증시 위치 정보 받아오기 시작
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    // 위치 요청 시작
    private func beginLocationUpdates(locationManager: CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // 화면 포커스
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000) // 2km, 2km
        mapView.setRegion(zoomRegion, animated: true)
    }
    
    @IBAction private func navigateStart(_ sender: UIButton) {
        guard let katecX = lastKactecX?.roundTo(places: 0), let katecY = lastKactecY?.roundTo(places: 0) else { return }
        
        print(katecX, katecY)
        let destination = KNVLocation(name: stationName.text!,
                                      x: NSNumber(value: katecX),
                                      y: NSNumber(value: katecY))
        let options = KNVOptions()
        options.routeInfo = false
        let params = KNVParams(destination: destination, options: options)
        KNVNaviLauncher.shared().navigate(with: params) { (error) in
            self.handleError(error: error)
        }
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!, message: error.localizedFailureReason, preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}


// MARK: - CLLocationManagerDelegate
extension MapViewController: CLLocationManagerDelegate {
    
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
    }
    
    // 위치 업데이트
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let newLocation = locations.last else { return }
        
        if currentCoordinate == nil {
            zoomToLatestLocation(with: newLocation.coordinate)
        }
        
        currentCoordinate = newLocation.coordinate
    }
    
    // 인증 상태가 변경 되었을 때
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
}

// MARK: - MKMapViewDelegate
extension MapViewController: MKMapViewDelegate {
    // 마커 뷰 관련 설정 Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if !annotation.isKind(of: ImageAnnotation.self) {
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "DefaultPinView")
            }
            return pinAnnotationView
        }
        
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation, reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! ImageAnnotation
        view?.annotation = annotation
        view?.priceLabel.text = String(annotation.price!)
        view?.coordinate = annotation.coordinate
        view?.image = annotation.image
        view?.name = annotation.name
        view?.distance = annotation.distance
        view?.katecX = annotation.katecX
        view?.katecY = annotation.katecY
        
        return view
    }
    
    // 마커 선택 Delegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let imageView = view as? ImageAnnotationView else { return }
        
        imageView.priceLabel.textColor = UIColor.red
        self.logoType.image = imageView.image
        self.stationName.text = imageView.name
        self.lastKactecX = imageView.katecX
        self.lastKactecY = imageView.katecY
        
        if let distance = imageView.distance, let price = imageView.priceLabel.text {
            let kmDistance = distance / 1000
            self.distance.text = String(kmDistance.roundTo(places: 2)) + "km"
            self.oilPrice.text = price + "원"
        }
        
        
        self.currentPlacemark = MKPlacemark(coordinate: imageView.coordinate!)
        
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
                self.mapView.removeOverlays(self.mapView.overlays) // 이전 경로 삭제
                self.mapView.add(route.polyline, level: .aboveRoads) // 경로 추가
            }
        }
        
    }
    
    // 마커 선택해제 관련 Delegate
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let imageView = view as? ImageAnnotationView
        imageView?.priceLabel.textColor = UIColor.black
        
        self.mapView.removeOverlays(self.mapView.overlays) // 경로 삭제
    }
    
    // 경로관련 선 옵션 Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 2.0
        
        return renderer
    }
    
}
