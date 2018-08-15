//
//  ViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MainListViewController: UIViewController {
    //CoreLocation
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    var priceDataList: [AllPrice] = []
    
    //Reverse Geocoding
    let geocoder = CLGeocoder() // 지오코딩을 수행할 객체
    var performingReverseGeocoding = false // 아직 위치가 없거나 주소가 일치 하지 않을 때는 주소를 받지 않을 것이므로
                                           // Bool변수로 받을 지 안받을 지 선택한다.
    var lastGeocodingError: Error? // 문제가 발생 했을 때 오류 저장 변수
    
    //Detail View
    @IBOutlet private weak var logoType : UIImageView!
    @IBOutlet private weak var stationName : UILabel!
    @IBOutlet private weak var distance : UILabel!
    @IBOutlet private weak var oilPrice : UILabel!
    @IBOutlet private weak var oilType : UILabel!
    
    //Map Kit
    @IBOutlet private weak var appleMapView: MKMapView!
    private var currentCoordinate: CLLocationCoordinate2D?
    var currentPlacemark: CLPlacemark? // 주소결과가 들어있는 객체
    var annotations: [ImageAnnotation] = [] // 마커 배열 생성
    
    //HeaderView
    @IBOutlet private weak var haderView : MainHeaderView!
    
    //Etc
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    @IBOutlet private weak var tableView : UITableView!
    @IBOutlet private weak var tableListView : UIView!
    @IBOutlet private weak var mapView : UIView!
    private var lastKactecX: Double?
    private var lastKactecY: Double?
    var selectIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.contentInset = UIEdgeInsets(top: -20, left: 0, bottom: 0, right: 0)
        //Navigation Bar 색상 설정
        UINavigationBar.appearance().barTintColor = self.view.backgroundColor
        allPriceDataLoad()
        appDelegate.mainViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLocationServices()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        appleMapView.removeAnnotations(annotations)
        annotations = []
        currentCoordinate = nil
        
        
    }
    
    private func gasStationListData(katecPoint: KatecPoint){
        ServiceList.gasStationList(x: katecPoint.x,
                                   y: katecPoint.y,
                                   radius: DefaultData.shared.radius,
                                   prodcd: DefaultData.shared.oilType,
                                   sort: 1,
                                   appKey: Preferences.getAppKey()) { (result) in
            
            switch result {
            case .success(let gasStationData):
                DefaultData.shared.data = gasStationData.result.gasStations
                self.showMarker()
                self.tableView.reloadData()
            case .error(let error):
                print(error)
                
            }
        }
    }
    
    func allPriceDataLoad() {
        ServiceList.allPriceList(appKey: Preferences.getAppKey()) { (result) in
            switch result {
            case .success(let allPriceListData):
                self.priceDataList = allPriceListData.result.allPriceList
                print("BYE!!!!")
                print(self.priceDataList)
            case .error(let err):
                print("ERROR!!!!!!")
                print(err)
            }
        }
    }
    
    //MARK: MapKit 관련
    // 마커 생성
    func showMarker() {
        guard let gasStations = DefaultData.shared.data else { return }
        
        for i in 0 ..< gasStations.count {
            annotations.append(ImageAnnotation()) // 마커 생성
            annotations[i].coordinate = Converter.convertKatecToWGS(katec: KatecPoint(x: gasStations[i].katecX, y: gasStations[i].katecY)) // 마커 위치 선점
            annotations[i].stationInfo = gasStations[i] // 주유소 정보 전달
            self.appleMapView.addAnnotation(annotations[i]) // 맵뷰에 마커 생성
        }
    }
    
    // 화면 포커스
    private func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegionMakeWithDistance(coordinate, 2000, 2000) // 2km, 2km
        appleMapView.setRegion(zoomRegion, animated: true)
    }
    
    // 리스트 전환 액션
    @IBAction private func toList(_ sender: UIButton) {
        self.view.sendSubview(toBack: self.mapView)
    }
    
    // 지도 전환 액션
    @IBAction private func toMap(_ sender: UIButton) {
        self.view.sendSubview(toBack: self.tableListView)
    }
    
    @IBAction private func navigateStart(_ sender: UIButton) {
        guard let katecX = lastKactecX?.roundTo(places: 0),
            let katecY = lastKactecY?.roundTo(places: 0) else { return }
        
        let destination = KNVLocation(name: stationName.text!,
                                      x: NSNumber(value: katecX),
                                      y: NSNumber(value: katecY))
        let options = KNVOptions()
        options.routeInfo = false
        let params = KNVParams(destination: destination,
                               options: options)
        KNVNaviLauncher.shared().navigate(with: params) { (error) in
            self.handleError(error: error)
        }
    }
    
    func handleError(error: Error?) -> Void {
        if let error = error as NSError? {
            print(error)
            let alert = UIAlertController(title: self.title!,
                                          message: error.localizedFailureReason,
                                          preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel,
                                          handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // 위치 관련 인증 확인
    func configureLocationServices() {
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
    private func startLocationUpdates(locationManager: CLLocationManager) {
        appleMapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // 위치 검색 중지
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
    }
    
    // 주소 한글 변환
    func string(from placemark: CLPlacemark) -> String {
        // address
        var address = ""
        if let s = placemark.administrativeArea {
            address += s + " "
        }
        if let s = placemark.locality {
            address += s + " "
        }
        if let s = placemark.thoroughfare {
            address += s + " "
        }
        if let s = placemark.subThoroughfare {
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
            if currentCoordinate == nil {
                zoomToLatestLocation(with: newLocation!.coordinate)
            }
            
            currentCoordinate = newLocation!.coordinate
            
            let katecPoint = Converter.convertWGS84ToKatec(coordinate: newLocation!.coordinate)
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                
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
                    self.haderView.configure(with: self.string(from: self.currentPlacemark!))
                })
            }
            
            gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
            stopLocationManager()
        }
        
        // 인증 상태가 변경 되었을 때
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == .authorizedAlways || status == .authorizedWhenInUse {
                startLocationUpdates(locationManager: manager)
            }
        }
    }
}

// MARK: - UITableView
extension MainListViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard let stationCount = DefaultData.shared.data?.count else { return 0 }
        return stationCount
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gasStations = DefaultData.shared.data else {
            return UITableViewCell()
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "GasStationCell") as! GasStationCell
        
        if selectIndexPath?.section == indexPath.section {
            cell.stationView.stackView.isHidden = false
        }
        
        cell.selectionStyle = .none
        cell.configure(with: gasStations[indexPath.section])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectPath = self.selectIndexPath else {
            let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
            cell.stationView.stackView.isHidden = false
            cell.selectionStyle = .none
            self.selectIndexPath = indexPath
            
            tableView.beginUpdates()
            tableView.endUpdates()
            return
        }
        
        if indexPath.section != selectPath.section {
            if let newCell = tableView.cellForRow(at: indexPath) as? GasStationCell {
                newCell.selectionStyle = .none
                newCell.stationView.stackView.isHidden = false
            }
            if let oldCell = tableView.cellForRow(at: selectPath) as? GasStationCell {
                oldCell.stationView.stackView.isHidden = true
            }
            self.selectIndexPath = indexPath
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? GasStationCell {
                if cell.stationView.stackView.isHidden {
                    cell.stationView.stackView.isHidden = false
                } else {
                    cell.stationView.stackView.isHidden = true
                    selectIndexPath = nil
                }
            }
        }
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectSection = self.selectIndexPath?.section else { return 100 }
        if indexPath.section == selectSection {
            return 150
        } else {
            return 100
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 12
    }
}

extension MainListViewController: UITableViewDelegate {
    
}

// MARK: - MKMapViewDelegate
extension MainListViewController: MKMapViewDelegate {
    // 마커 뷰 관련 설정 Delegate
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation.isKind(of: MKUserLocation.self) {
            return nil
        }
        
        if !annotation.isKind(of: ImageAnnotation.self) {
            var pinAnnotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "DefaultPinView")
            if pinAnnotationView == nil {
                pinAnnotationView = MKPinAnnotationView(annotation: annotation,
                                                        reuseIdentifier: "DefaultPinView")
            }
            return pinAnnotationView
        }
        
        var view: ImageAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: "imageAnnotation") as? ImageAnnotationView
        if view == nil {
            view = ImageAnnotationView(annotation: annotation,
                                       reuseIdentifier: "imageAnnotation")
        }
        
        let annotation = annotation as! ImageAnnotation
        view?.annotation = annotation
        view?.stationInfo = annotation.stationInfo
        
        if let stationInfo = annotation.stationInfo {
            view?.priceLabel.text = String(stationInfo.price)
            view?.coordinate = annotation.coordinate
            view?.image = Preferences.logoImage(logoName: stationInfo.brand)
        }
        
        return view
    }
    
    // 마커 선택 Delegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let markerView = view as? ImageAnnotationView else { return }
        guard let stationInfo = markerView.stationInfo else { return }
        
        self.logoType.image = markerView.image
        let kmDistance = stationInfo.distance / 1000
        self.stationName.text = stationInfo.name
        self.lastKactecX = stationInfo.katecX
        self.lastKactecY = stationInfo.katecY
        
        self.distance.text = String(kmDistance.roundTo(places: 2)) + "km"
        self.oilPrice.text = String(stationInfo.price) + "원"
        self.oilType.text = Preferences.oil(code: DefaultData.shared.oilType)
        markerView.firstImageView.image = UIImage(named: "SelectMapMarker")
        markerView.priceLabel.textColor = UIColor.white
        
        
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
        
    }
    
    // 마커 선택해제 관련 Delegate
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let markerView = view as? ImageAnnotationView
        markerView?.firstImageView.image = UIImage(named: "NonMapMarker")
        markerView?.priceLabel.textColor = UIColor.black
        
        self.appleMapView.removeOverlays(self.appleMapView.overlays) // 경로 삭제
    }
    
    // 경로관련 선 옵션 Delegate
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        
        renderer.strokeColor = UIColor(named: "MainColor")?.withAlphaComponent(0.8)
        renderer.lineWidth = 5.0
        
        return renderer
    }
}
