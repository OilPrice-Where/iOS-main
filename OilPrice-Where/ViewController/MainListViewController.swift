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
    var locationManager = CLLocationManager() // locationManager
    var oldLocation: CLLocation?
    var lastLocationError: Error? // Location Error 확인
    
    //Reverse Geocoding
    let geocoder = CLGeocoder() // 지오코딩을 수행할 객체
    var performingReverseGeocoding = false // 아직 위치가 없거나 주소가 일치 하지 않을 때는 주소를 받지 않을 것이므로
                                           // Bool변수로 받을 지 안받을 지 선택한다.
    var lastGeocodingError: Error? // 문제가 발생 했을 때 오류 저장 변수
    private var lastContentOffset: CGFloat = 0 // 테이블 뷰 스크롤의 현재 위치 저장함수
    
    // Map
    @IBOutlet private weak var appleMapView: MKMapView! // 맵 뷰
    private var currentCoordinate: CLLocationCoordinate2D? // 현재 좌표
    var currentPlacemark: CLPlacemark? // 주소결과가 들어있는 객체
    var annotations: [CustomMarkerAnnotation] = [] // 마커 배열 생성
    @IBOutlet private weak var mapView : UIView!
    
    // Detail View
    @IBOutlet private weak var detailView : DetailView! // Detail View
    
    // TableView
    @IBOutlet private weak var tableListView : UIView! // 테이블 뷰를 포함하고 있는 뷰
    @IBOutlet private weak var tableView : UITableView! // 메인리스트 테이블 뷰
    var selectIndexPath: IndexPath? // 선택된 인덱스 패스
    var refreshControl = UIRefreshControl() // Refresh Controller
    
    // HeaderView
    @IBOutlet private weak var haderView : MainHeaderView!
    @IBOutlet weak var toListButton : UIView!
    @IBOutlet private weak var toImageView : UIImageView!
    @IBOutlet private weak var toLabel : UILabel!
    var mainListPage = true
    var tapGesture = UITapGestureRecognizer()
    var sortData: [GasStation] = []
    
    // StatusBarBackView
    @IBOutlet weak var statusBarBackView: UIView!
    @IBOutlet weak var headerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: MainHeaderView!
    
    //Etc
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트
    private var lastKactecX: Double? // KatecX 좌표
    private var lastKactecY: Double? // KatecY 좌표
    var lastOilType = DefaultData.shared.oilType
    var lastFindRadius = DefaultData.shared.radius
    var selectMarker = false
    var lastBottomConstant: CGFloat?
    var priceSortButton: UIButton!
    var distanceSortButton: UIButton!
    var lastSelectedSortButton: UIButton!
    
    func setStatusBarBackgroundColor(color: UIColor) {
        
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createSortView()
        setting()
        setStatusBarBackgroundColor(color: .clear)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureLocationServices()
        if mainListPage {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
        
    }

    func reset() {
        appleMapView.removeAnnotations(annotations)
        annotations = []
        currentCoordinate = nil
        selectIndexPath = nil
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
                print("DataLoad")
                DefaultData.shared.data = gasStationData.result.gasStations
                self.sortData = gasStationData.result.gasStations.sorted(by: {$0.distance < $1.distance})
                self.showMarker()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            case .error(let error):
                print(error)
            }
        }
    }
    
    
    /// tableView refreshControll 함수
    @objc func refresh() {
        oldLocation = nil
        reset()
        configureLocationServices()
    }
    
    func setting() {
        // Navigation Bar 색상 설정
        UINavigationBar.appearance().barTintColor = UIColor(named: "MainColor")
        appDelegate.mainViewController = self
        
        self.toListButton.layer.cornerRadius = self.toListButton.bounds.height / 2
        self.toImageView.image = toImageView.image!.withRenderingMode(.alwaysTemplate)
        self.toImageView.tintColor = UIColor.white
        
        toListButton.clipsToBounds = false
        toListButton.layer.shadowColor = UIColor.black.cgColor
        toListButton.layer.shadowOpacity = 0.5
        toListButton.layer.shadowOffset = CGSize(width: 0, height: 3)
        toListButton.layer.shadowRadius = 2
        
        // Draw a shadow
        toListButton.layer.shadowPath = UIBezierPath(roundedRect: toListButton.bounds, cornerRadius: self.toListButton.bounds.height / 2).cgPath
        // Add image into container
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toList(_:)))
        toListButton.addGestureRecognizer(tap)
        // 테이블 뷰 헤더 경계 값 설정
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 새로 고침
        self.refreshControl.addTarget(self,
                                 action: #selector(refresh),
                                 for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = self.refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    func createSortView() {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        self.priceSortButton = UIButton(frame: CGRect(x: 15, y: 0, width: 45, height: 30))
        self.priceSortButton.setTitle("가격순", for: .normal)
        self.priceSortButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.priceSortButton.setTitleColor(UIColor(named: "MainColor"), for: .selected)
        self.priceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
        self.priceSortButton.tag = 1
        self.priceSortButton.isSelected = true
        self.priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        sectionHeaderView.addSubview(self.priceSortButton)
        
        distanceSortButton = UIButton(frame: CGRect(x: 69, y: 0, width: 45, height: 30))
        self.distanceSortButton.setTitle("거리순", for: .normal)
        self.distanceSortButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.distanceSortButton.setTitleColor(UIColor(named: "MainColor"), for: .selected)
        self.distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
        self.distanceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
        self.distanceSortButton.tag = 2
        sectionHeaderView.addSubview(distanceSortButton)
        
        lastSelectedSortButton = priceSortButton
        tableView.addSubview(sectionHeaderView)
    }
    
    @objc func isTableViewSort(_ sender: UIButton) {
        guard lastSelectedSortButton.tag != sender.tag else {
            return
        }
        if sender.tag == priceSortButton.tag {
            priceSortButton.isSelected = true
            priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
            distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
            distanceSortButton.isSelected = false
            
            lastSelectedSortButton = priceSortButton
        } else {
            distanceSortButton.isSelected = true
            distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
            priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
            priceSortButton.isSelected = false
            
            lastSelectedSortButton = distanceSortButton
        }
        selectIndexPath = nil
        appleMapView.removeAnnotations(annotations)
        annotations = []
        showMarker()
        tableView.reloadData()
    }
    
    //MARK: MapKit 관련
    // 마커 생성
    func showMarker() {
        guard var gasStations = DefaultData.shared.data else { return }
        if distanceSortButton.isSelected {
            gasStations = sortData
        } else {
            gasStations = DefaultData.shared.data!
        }
        
        for i in 0 ..< gasStations.count {
            annotations.append(CustomMarkerAnnotation()) // 마커 생성
            annotations[i].coordinate = Converter.convertKatecToWGS(katec: KatecPoint(x: gasStations[i].katecX, y: gasStations[i].katecY)) // 마커 위치 선점
            annotations[i].stationInfo = gasStations[i] // 주유소 정보 전달
            self.appleMapView.addAnnotation(annotations[i]) // 맵뷰에 마커 생성

        }
    }
    
    // 화면 포커스
    func zoomToLatestLocation(with coordinate: CLLocationCoordinate2D) {
        let zoomRegion = MKCoordinateRegionMakeWithDistance(coordinate, 3000, 3000) // 2km, 2km
        appleMapView.setRegion(zoomRegion, animated: true)
    }
    
    // 전환 액션
    @objc func toList(_ sender: UIView) {
        if mainListPage {
            UIApplication.shared.statusBarStyle = .default
            self.view.sendSubview(toBack: self.tableListView)
            toImageView.image = UIImage(named: "listButton")
            toLabel.text = "목록"
            if lastBottomConstant == 10 {
                if let indexPath = selectIndexPath {
                    let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
                    if cell.stationView.id == detailView.id {
                        if detailView.favoriteButton.isSelected != cell.stationView.favoriteButton.isSelected {
                            self.detailView.clickedEvent(detailView.favoriteButton)
                        }
                    }
                    self.detailView.detailViewBottomConstraint.constant = 10
                    UIView.animate(withDuration: 0.3) {
                        self.view.layoutIfNeeded()
                    }
                }
            } else {
                self.detailView.detailViewBottomConstraint.constant = -150
                UIView.animate(withDuration: 0.3) {
                    self.view.layoutIfNeeded()
                }
            }
            statusBarBackView.isHidden = true
            mainListPage = false
        } else {
            UIApplication.shared.statusBarStyle = .lightContent
            self.view.sendSubview(toBack: self.mapView)
            toImageView.image = UIImage(named: "mapButton")
            toLabel.text = "지도"
            lastBottomConstant = self.detailView.detailViewBottomConstraint.constant
            self.detailView.detailViewBottomConstraint.constant = -150
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
            statusBarBackView.isHidden = false
            mainListPage = true
        }
        tableView.reloadData()
    }
    
    // 지도 보기
    @objc func viewMapAction(annotionIndex gesture: UITapGestureRecognizer) {
        guard let index = self.selectIndexPath?.section else { return }
 
        self.toList(self.toListButton)
        
        appleMapView.selectAnnotation(self.annotations[index], animated: true)
    }
    
    // 길안내 시작
    @objc func navigateStart(_ sender: UITapGestureRecognizer) {
        guard let katecX = lastKactecX?.roundTo(places: 0),
              let katecY = lastKactecY?.roundTo(places: 0) else { return }
        
        let destination = KNVLocation(name: detailView.stationName.text!,
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
    
    // 길안내 에러 발생
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
            if let lastLocation = oldLocation {
                let distance: CLLocationDistance = newLocation!.distance(from: lastLocation)
                if distance < 50.0 &&
                   lastOilType == DefaultData.shared.oilType &&
                   lastFindRadius == DefaultData.shared.radius {
                   
                   stopLocationManager()
                } else {
                    reset()
                    gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
                    stopLocationManager()
                    oldLocation = newLocation
                    lastOilType = DefaultData.shared.oilType
                    lastFindRadius = DefaultData.shared.radius
                }
            } else {
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
        guard var gasStations = DefaultData.shared.data else {
            return UITableViewCell()
        }
        
        if distanceSortButton.isSelected {
            gasStations = sortData
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GasStationCell") as! GasStationCell
        
        cell.addGestureRecognize(self, action: #selector(self.viewMapAction(annotionIndex:)))
        cell.configure(with: gasStations[indexPath.section])
        
        if selectIndexPath?.section == indexPath.section {
            cell.stationView.stackView.isHidden = false
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectPath = self.selectIndexPath else {
            let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
            cell.stationView.stackView.isHidden = false
            cell.stationView.favoriteButtonUpdateFrame()
            cell.selectionStyle = .none
            self.selectIndexPath = indexPath
            
            tableView.reloadData()
            return
        }
        
        if indexPath.section != selectPath.section {
            if let newCell = tableView.cellForRow(at: indexPath) as? GasStationCell {
                newCell.selectionStyle = .none
                newCell.stationView.stackView.isHidden = false
                newCell.stationView.favoriteButtonUpdateFrame()
            }
            if let oldCell = tableView.cellForRow(at: selectPath) as? GasStationCell {
                oldCell.stationView.stackView.isHidden = true
            }
            self.selectIndexPath = indexPath
        } else {
            if let cell = tableView.cellForRow(at: indexPath) as? GasStationCell {
                if cell.stationView.stackView.isHidden {
                    cell.stationView.stackView.isHidden = false
                    cell.stationView.favoriteButtonUpdateFrame()
                } else {
                    cell.stationView.stackView.isHidden = true
                    selectIndexPath = nil
                }
            }
        }
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectSection = self.selectIndexPath?.section else { return 110 }
        if indexPath.section == selectSection {
            return 164
        } else {
            return 110
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 30
        } else {
            return 12
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.00001
    }
}


// MARK: - UITableViewDelegate
extension MainListViewController: UITableViewDelegate {
    
    /// 스크롤 옵셋에 따른 헤더뷰 위치 변경
    ///
    /// - 코드 리펙토링 필요
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == tableView {
            let setHeaderViewConstraint = headerViewConstraint.constant - scrollView.contentOffset.y
            if (self.lastContentOffset > scrollView.contentOffset.y) {
                if scrollView.contentOffset.y <= 0 {
                    if -(setHeaderViewConstraint) >= 0 {
                        headerViewConstraint.constant = setHeaderViewConstraint
                        scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                    }else {
                        headerViewConstraint.constant = 0
                    }
                }
            }
            else if (self.lastContentOffset < scrollView.contentOffset.y) {
                if -(setHeaderViewConstraint) >= haderView.frame.size.height {
                    headerViewConstraint.constant = -(haderView.frame.size.height)
                }else if -(setHeaderViewConstraint) >= 0{
                    headerViewConstraint.constant = setHeaderViewConstraint
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }else{
                    headerViewConstraint.constant = 0
                    scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
            }

            // 현재 테이블 뷰 컨텐츠 옵션의 위치 저장
            self.lastContentOffset = scrollView.contentOffset.y
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
        
        if let stationInfo = annotation.stationInfo {
            view?.priceLabel.text = String(stationInfo.price)
            view?.coordinate = annotation.coordinate
            view?.image = Preferences.logoImage(logoName: stationInfo.brand)
        }
        
        return view
    }
    
    // 마커 선택 Delegate
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let markerView = view as? CustomMarkerAnnotationView else { return }
        guard let stationInfo = markerView.stationInfo else { return }
        

        self.lastKactecX = stationInfo.katecX
        self.lastKactecY = stationInfo.katecY
        
        detailView.configure(stationInfo)
        detailView.detailViewTapGestureRecognizer(target: self, action: #selector(self.navigateStart(_:)))
        markerView.mapMarkerImageView.image = UIImage(named: "SelectMapMarker")
        markerView.priceLabel.textColor = UIColor.white
        
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
        zoomToLatestLocation(with: markerView.coordinate!)
        
    }
    
    // 마커 선택해제 관련 Delegate
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let markerView = view as? CustomMarkerAnnotationView
        markerView?.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
        markerView?.priceLabel.textColor = UIColor.black
        
        self.detailView.detailViewBottomConstraint.constant = -150
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
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
