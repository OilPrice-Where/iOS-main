//
//  ViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.

import UIKit
import MapKit
import CoreLocation
import SCLAlertView

class MainListViewController: UIViewController {
    //CoreLocation
    var locationManager = CLLocationManager() // locationManager
    var oldLocation: CLLocation?
    var lastLocationError: Error? // Location Error 확인
    let firebaseUtility = FirebaseUtility()
    
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
    @IBOutlet private weak var mapView : UIView! // 애플맵을 포함시키고 있는 뷰
    @IBOutlet private weak var currentLocationButton : UIButton! // 현재 위치 표시 버튼
    
    // Detail View
    @IBOutlet private weak var detailView : DetailView! // Detail View
    
    // TableView
    @IBOutlet private weak var tableListView : UIView! // 테이블 뷰를 포함하고 있는 뷰
    @IBOutlet private weak var tableView : UITableView! // 메인리스트 테이블 뷰
    var selectIndexPath: IndexPath? // 선택된 인덱스 패스
    var refreshControl = UIRefreshControl() // Refresh Controller
    
    // HeaderView
    @IBOutlet weak var toListButton : UIView! //
    @IBOutlet private weak var toImageView : UIImageView!
    @IBOutlet private weak var toLabel : UILabel!
    @IBOutlet weak var headerViewConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerView: MainHeaderView!
    @IBOutlet weak var priceView: UIView!
    
    @IBOutlet private weak var mainProductTitleLabel : UILabel!
    @IBOutlet private weak var mainProductCostLabel : UILabel!
    @IBOutlet private weak var mainProductImageView : UIImageView!
    
    @IBOutlet private weak var secondProductTitleLabel : UILabel!
    @IBOutlet private weak var secondProductCostLabel : UILabel!
    @IBOutlet private weak var secondProductImageView : UIImageView!
    
    @IBOutlet private weak var thirdProductTitleLabel : UILabel!
    @IBOutlet private weak var thirdProductCostLabel : UILabel!
    @IBOutlet private weak var thirdProductImageView : UIImageView!
    
    var mainListPage = true
    var tapGesture = UITapGestureRecognizer()
    var sortData: [GasStation] = []
    
    // StatusBarBackView
    @IBOutlet weak var statusBarBackView: UIView!
    
    //Etc
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate // 앱 델리게이트
    private var lastKactecX: Double? // KatecX 좌표
    private var lastKactecY: Double? // KatecY 좌표
    var lastOilType = DefaultData.shared.oilType // 마지막 오일 타입
    var lastFindRadius = DefaultData.shared.radius // 마지막 탐색 범위
    var lastFavorites = DefaultData.shared.favoriteArr // 마지막 즐겨 찾기 목록
    var selectMarker = false // 마커 선택 여부
    var lastBottomConstant: CGFloat? // 전환 버튼 애니메이션 관련 Bottom Constraint
    var priceSortButton: UIButton! // 가격 순으로 정렬 해주는 버튼
    var distanceSortButton: UIButton! // 거리 순으로 정렬 해주는 버튼
    var lastSelectedSortButton: UIButton! // 마지막 정렬
    @IBOutlet private weak var noneView: UIView! // 리스트가 아무 것도 없을 때 보여주는 뷰
    @IBOutlet private weak var noneLabel : UILabel! // NoneView에 보여줄 Label
    
    func setStatusBarBackgroundColor(color: UIColor) {
        guard let statusBar = UIApplication.shared.value(forKeyPath: "statusBarWindow.statusBar") as? UIView else { return }
        statusBar.backgroundColor = color
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setStatusBarBackgroundColor(color: .clear) // StatusBar 배경색 설정
        createSortView() // 가격순, 거리순 버튼 생성 및 설정
        setting() // 기본 설정
        setAverageCosts() // HeaderView 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 메인리스트 / 맵 일때 StatusBarStyle 설정
        if mainListPage {
            UIApplication.shared.statusBarStyle = .lightContent
        } else {
            UIApplication.shared.statusBarStyle = .default
        }
        
        // ViewWillAppear시 네트워크 연결 확인
        if Reachability.isConnectedToNetwork() { // 네트워크 연결 시 로케이션 서비스 시작
            configureLocationServices()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 네트워크 연결이 되어 있지 않을 때 Alert 호출
        if !Reachability.isConnectedToNetwork() {
            // Alert 설정
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: 300, // Alert Width
                kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!, // Alert Title Font
                kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!, // Alert Content Font
                showCloseButton: true // CloseButton isHidden = True
            )

            let alert = SCLAlertView(appearance: appearance)
            alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
            alert.iconTintColor = UIColor.white
            
            // 네트워크 연결이 안 되어 있으므로 초기화
            reset()
            DefaultData.shared.data = nil
            sortData = []
            tableView.reloadData()
        }
    }
    
    //Mark: 기본 설정 (viewDidLoad)
    // 가격순, 거리순 버튼 생성
    func createSortView() {
        let sectionHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: 30))
        
        // 가격순 버튼 설정
        self.priceSortButton = UIButton(frame: CGRect(x: 15, y: 0, width: 45, height: 30))
        self.priceSortButton.setTitle("가격순", for: .normal)
        self.priceSortButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.priceSortButton.setTitleColor(UIColor(named: "MainColor"), for: .selected)
        self.priceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
        self.priceSortButton.tag = 1
        self.priceSortButton.isSelected = true
        self.priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
        sectionHeaderView.addSubview(self.priceSortButton)
        
        // 거리순 버튼 설정
        distanceSortButton = UIButton(frame: CGRect(x: 69, y: 0, width: 45, height: 30))
        self.distanceSortButton.setTitle("거리순", for: .normal)
        self.distanceSortButton.setTitleColor(UIColor.darkGray, for: .normal)
        self.distanceSortButton.setTitleColor(UIColor(named: "MainColor"), for: .selected)
        self.distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
        self.distanceSortButton.addTarget(self, action: #selector(self.isTableViewSort(_:)), for: .touchUpInside)
        self.distanceSortButton.tag = 2
        sectionHeaderView.addSubview(distanceSortButton)
        
        // 기본 설정 버튼(가격순)
        lastSelectedSortButton = priceSortButton
        
        tableView.addSubview(sectionHeaderView)
    }
    
    // 기본 세팅
    func setting() {
        self.noneLabel.font = UIFont(name: "NanumSquareRoundB", size: 17) //NoneView 내의 NoneLabel 설정
        priceView.layer.cornerRadius = 10
        
        // currentLocationButton 설정
        currentLocationButton.layer.cornerRadius = self.currentLocationButton.bounds.height / 2
        currentLocationButton.clipsToBounds = false
        currentLocationButton.layer.shadowColor = UIColor.black.cgColor
        currentLocationButton.layer.shadowOpacity = 0.3
        currentLocationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        currentLocationButton.layer.shadowRadius = 1.5
        currentLocationButton.addTarget(self, action: #selector(self.currentLoaction(_:)), for: .touchUpInside)
        
        // Draw a shadow
        currentLocationButton.layer.shadowPath = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                                              cornerRadius: self.currentLocationButton.bounds.height / 2).cgPath
        
        // Navigation Bar 색상 설정
        UINavigationBar.appearance().barTintColor = UIColor(named: "MainColor")
        appDelegate.mainViewController = self
        
        // 전환 버튼 설정
        self.toListButton.layer.cornerRadius = self.toListButton.bounds.height / 2
        self.toImageView.image = toImageView.image!.withRenderingMode(.alwaysTemplate)
        self.toImageView.tintColor = UIColor.white
        // 전환 버튼 그림자 설정
        toListButton.clipsToBounds = false
        toListButton.layer.shadowColor = UIColor.black.cgColor
        toListButton.layer.shadowOpacity = 0.5
        toListButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        toListButton.layer.shadowRadius = 2
        
        // Draw a shadow
        toListButton.layer.shadowPath = UIBezierPath(roundedRect: toListButton.bounds, cornerRadius: self.toListButton.bounds.height / 2).cgPath
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.toList(_:)))
        toListButton.addGestureRecognizer(tap)
        
        // 테이블 뷰 헤더 경계 값 설정
        self.tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        // 테이블뷰내에 Refresh 설정
        self.refreshControl.addTarget(self,
                                      action: #selector(refresh),
                                      for: UIControlEvents.valueChanged)
        if #available(iOS 10.0, *) { // iOS 버전 별 설정
            tableView.refreshControl = self.refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }
    
    // HeaderView 설정
    func setAverageCosts() {
        firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
            self.mainProductCostLabel.text = data["price"] as? String ?? ""
            self.mainProductTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.mainProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
            }else {
                self.mainProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
            }
        }
        firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
            self.secondProductCostLabel.text = data["price"] as? String ?? ""
            self.secondProductTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.secondProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
            }else {
                self.secondProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
            }
            
        }
        firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
            self.thirdProductCostLabel.text = data["price"] as? String ?? ""
            self.thirdProductTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.thirdProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
            } else {
                self.thirdProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
            }
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
                DefaultData.shared.data = gasStationData.result.gasStations
                self.sortData = gasStationData.result.gasStations.sorted(by: {$0.distance < $1.distance})
                self.showMarker()
                self.isDisplayNoneView()
                self.refreshControl.endRefreshing()
                self.tableView.reloadData()
            case .error(let error):
                print(error)
            }
        }
    }
    
    func isDisplayNoneView() {
        if self.sortData.count == 0 {
            self.noneView.isHidden = false
        } else {
            self.noneView.isHidden = true
        }
    }
    
    //Mark: Display 관련 설정
    // Reload
    @objc func refresh() {
        oldLocation = nil
        reset()
        configureLocationServices()
    }
    
    // TableView List Sort Func(가격, 거리)
    @objc func isTableViewSort(_ sender: UIButton) {
        guard lastSelectedSortButton.tag != sender.tag else {
            return
        }
        
        if sender.tag == priceSortButton.tag { // Sender와 priceButton과 같을 시에 가격순 정렬
            priceSortButton.isSelected = true
            priceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundEB", size: 16)
            distanceSortButton.titleLabel?.font = UIFont(name: "NanumSquareRoundR", size: 16)
            distanceSortButton.isSelected = false
            
            lastSelectedSortButton = priceSortButton
        } else { // 거리순 정렬
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
    
    // 전환 액션
    @objc func toList(_ sender: UIView) {
        if mainListPage { // 메인리스트 페이지 일시 맵뷰로 전환
            UIApplication.shared.statusBarStyle = .default // 맵뷰로 전환 시 statusBarStyle
            self.view.sendSubview(toBack: self.tableListView)
            
            // 전환 버튼 애니메이션 관련
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
            
            toLabel.text = "목록"
            toImageView.image = UIImage(named: "listButton")
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
    
    // 맵의 현재위치 버튼
    @objc func currentLoaction(_ sender: UIButton) {
        if Reachability.isConnectedToNetwork() {
            guard let coordinate = self.currentCoordinate else { return }
            zoomToLatestLocation(with: coordinate)
        } else {
            let appearance = SCLAlertView.SCLAppearance(
                kWindowWidth: 300,
                kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!,
                kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!,
                showCloseButton: true
            )
            
            let alert = SCLAlertView(appearance: appearance)
            
            alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
            alert.iconTintColor = UIColor.white
        }
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
                    self.headerView.configure(with: self.string(from: self.currentPlacemark))
                })
            }
            if let lastLocation = oldLocation {
                let distance: CLLocationDistance = newLocation!.distance(from: lastLocation)
                if distance < 50.0 &&
                   lastOilType == DefaultData.shared.oilType &&
                   lastFindRadius == DefaultData.shared.radius &&
                   lastFavorites == DefaultData.shared.favoriteArr {
                   stopLocationManager()
                   self.tableView.reloadData()
                } else {
                    reset()
                    gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
                    stopLocationManager()
                    oldLocation = newLocation
                    lastOilType = DefaultData.shared.oilType
                    lastFindRadius = DefaultData.shared.radius
                    lastFavorites = DefaultData.shared.favoriteArr
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
    
    // cell의 높이 설정
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard let selectSection = self.selectIndexPath?.section else { return 110 }
        // 선택된 셀의 높이와 비선택 셀의 높이 설정
        if indexPath.section == selectSection {
            return 164
        } else {
            return 110
        }
    }
    
    // 섹션 사이의 값 설정
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        // 처음 섹션일 때 가격순, 거리순 정렬 버튼 삽입을 위해 조금 더 높게 설정
        if section == 0 {
            return 30
        } else {
            return 12
        }
    }
    
    // heightForFooterInSection
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
                if -(setHeaderViewConstraint) >= headerView.frame.size.height {
                    headerViewConstraint.constant = -(headerView.frame.size.height)
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
        
    }
    
    // 마커 선택해제 관련 Delegate
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        let markerView = view as? CustomMarkerAnnotationView
        markerView?.mapMarkerImageView.image = UIImage(named: "NonMapMarker")
        markerView?.priceLabel.textColor = UIColor.black
        
        // 디테일 뷰 하단으로 변경
        self.detailView.detailViewBottomConstraint.constant = -150
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        self.appleMapView.removeOverlays(self.appleMapView.overlays) // 경로 선 삭제
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
