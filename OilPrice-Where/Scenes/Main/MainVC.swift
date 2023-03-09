//
//  MainVC.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import CoreLocation
import UIKit
import RxSwift
import RxCocoa
import NMapsMap
import SideMenu
import Firebase
import FloatingPanel
//MARK: Main Map VC
final class MainVC: CommonViewController {
    //MARK: - Properties
    var ref: DatabaseReference?
    let viewModel = MainViewModel()
    private lazy var fpc = FloatingPanelController()
    private lazy var contentsVC = StationInfoVC() // 띄울 VC
    private lazy var mapContainerView = MainMapView()
    private lazy var guideView = StationInfoGuideView()
    private var circle: NMFCircleOverlay?
    private var noti: NSObjectProtocol?
    var bottomOffset: CGFloat = 36
    let emptyView = UIView().then {
        $0.backgroundColor = .white
    }
    lazy var sideMenu = SideMenuNavigationController(rootViewController: MenuVC()).then {
        var set = SideMenuSettings()
        set.statusBarEndAlpha = 0
        set.presentationStyle = SideMenuPresentationStyle.menuSlideIn
        set.presentationStyle.presentingEndAlpha = 0.65
        set.menuWidth = fetchSideMenuWidth()
        set.blurEffectStyle = nil
        $0.leftSide = true
        $0.settings = set
    }
    
    //MARK: - Life Cycle
    deinit {
        if let noti {
            NotificationCenter.default.removeObserver(noti)
        }
        self.noti = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configure()
        rxBind()
        appVersionCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarUIView?.backgroundColor = .clear
    }
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "주유 정보"
        view.backgroundColor = .white
        view.addSubview(mapContainerView)
        
        setupView()
        fpc.view.addSubview(guideView)
        fpc.view.addSubview(emptyView)
        
        mapContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mapContainerView.toFavoriteButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-bottomOffset)
            $0.right.equalTo(mapContainerView.currentLocationButton.snp.left).offset(-12)
            $0.size.equalTo(42)
        }
        mapContainerView.currentLocationButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-bottomOffset)
            $0.right.equalToSuperview().offset(-24)
            $0.size.equalTo(42)
        }
        mapContainerView.researchButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.centerX.equalTo(mapContainerView.snp.centerX)
            $0.width.equalTo(120)
            $0.height.equalTo(42)
        }
        guideView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(82)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(guideView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        mapContainerView.searchView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    private func updateFavoriteUI() {
        let ids = DefaultData.shared.favoriteSubject.value
        
        guard let id = viewModel.selectedStation?.id else { return }
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        DispatchQueue.main.async { [weak self] in
            self?.guideView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.guideView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
            self?.guideView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
        }
    }
    
    private func configure() {
        mapContainerView.delegate = self
        mapContainerView.mapView.touchDelegate = self
        mapContainerView.mapView.addCameraDelegate(delegate: self)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(toSearchVC))
        mapContainerView.searchView.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - Rx Binding..
    private func rxBind() {
        noti = NotificationCenter.default.addObserver(forName: NSNotification.Name("liveActivities"),
                                                      object: nil,
                                                      queue: .main) { [weak self] _ in
            guard let location = LocationManager.shared.requestLocation else { return }
            
            self?.viewModel.isLiveActivities = true
            self?.viewModel.requestLocation = location
            self?.viewModel.input.requestStaions.accept(nil)
        }
        
        DefaultData.shared.completedRelay
            .sink { [weak self] key in
                guard let owner = self,
                      !(key == "Favorites" || key == "LocalFavorites") else {
                    self?.updateFavoriteUI()
                    return
                }
                
                owner.reset()
                DispatchQueue.main.async {
                    owner.fpc.move(to: .hidden, animated: false, completion: nil)
                }
            }
            .store(in: &viewModel.cancelBag)
        
        LocationManager.shared.locationManager?
            .rx
            .didUpdateLocations
            .compactMap { $0.last }
            .subscribe(with: self, onNext: { owner, location in
                LocationManager.shared.currentLocation = location
                
                guard let _ = owner.viewModel.requestLocation else {
                    owner.mapContainerView.moveMap(with: location.coordinate)
                    owner.viewModel.requestLocation = location
                    owner.viewModel.input.requestStaions.accept(nil)
                    return
                }
            })
            .disposed(by: rx.disposeBag)
        // menuButton Tapped
        mapContainerView
            .searchView
            .menuButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.showSideMenu()
            })
            .disposed(by: rx.disposeBag)
        // toListButton Tapped
        mapContainerView
            .searchView
            .listButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.toListTapped()
            })
            .disposed(by: rx.disposeBag)
        // researchStation Tapped
        mapContainerView
            .researchButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.researchStation()
            })
            .disposed(by: rx.disposeBag)
        // toFavoriteButton Tapped
        mapContainerView
            .toFavoriteButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.toFavoriteTapped()
            })
            .disposed(by: rx.disposeBag)
        // favoriteButton Tapped
        guideView
            .favoriteButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.touchedFavoriteButton()
            })
            .disposed(by: rx.disposeBag)
        // directionButton Tapped
        guideView
            .directionButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.toNavigationTapped()
            })
            .disposed(by: rx.disposeBag)
        mapContainerView
            .currentLocationButton
            .rx
            .tap
            .compactMap { LocationManager.shared.currentLocation }
            .bind(to: mapContainerView.mapView.rx.center)
            .disposed(by: rx.disposeBag)
        
        
        viewModel.output.staionResult
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.circle?.mapView = nil
                owner.circle = owner.makeRadiusCircle(location: owner.viewModel.requestLocation)
                owner.circle?.mapView = owner.mapContainerView.mapView
                
                owner.mapContainerView.showMarker(list: owner.viewModel.stations)
                NotificationCenter.default.post(name: NSNotification.Name("stationsUpdated"),
                                                object: nil,
                                                userInfo: ["stations": owner.viewModel.stations])
                
                guard DefaultData.shared.backgroundFindSubject.value,
                      owner.viewModel.isLiveActivities,
                      let targetStation = LocationManager.shared.findStation,
                      let info = LocationManager.shared.stations.first(where: { $0.id == targetStation.id }),
                      let lat = targetStation.lat, let lng = targetStation.lng else { return }
                
                owner.sideMenu.dismiss(animated: false)
                owner.viewModel.isLiveActivities = false
                let position = NMGLatLng(lat: lat, lng: lng)
                owner.marker(didTapMarker: position, info: info)
                owner.mapContainerView.selectedMarker = owner.mapContainerView.markers.first(where: {
                    guard let station = $0.userInfo["station"] as? GasStation else { return false }
                    return station.id == targetStation.id
                })
                owner.mapContainerView.selectedMarker?.isSelected = true
                
                let update = NMFCameraUpdate(scrollTo: position, zoomTo: 15.0)
                update.animation = .easeIn
                owner.mapContainerView.mapView.moveCamera(update)
                
                owner.mapContainerView.researchButton.alpha = 0.0
                owner.mapContainerView.researchButton.snp.updateConstraints {
                    $0.top.equalTo(owner.view.safeAreaLayoutGuide)
                }
            })
            .disposed(by: viewModel.bag)
        // 즐겨찾기 목록의 StationID 값과 StationView의 StationID값이 동일 하면 선택 상태로 변경
        viewModel.output.selectedStation
            .subscribe(with: self, onNext: { owner, _ in
                owner.updateFavoriteUI()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Override Method
    override func setNetworkSetting() {
        super.setNetworkSetting()
        
        reachability?.whenReachable = { [weak self] _ in
            self?.viewModel.input.requestStaions.accept(nil)
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            self?.notConnect()
            self?.viewModel.requestLocation = nil
            LocationManager.shared.currentLocation = nil
            self?.reset()
            self?.mapContainerView.resetInfoWindows()
            self?.fpc.move(to: .hidden, animated: false, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sideMenu.dismiss(animated: false)
    }
    
    func fetchSideMenuWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return UIDevice.current.userInterfaceIdiom == .pad ? 328.0 : screenWidth * (240 / 375)
    }
    
    //MARK: - User Intraction
    private func showSideMenu() {
        present(sideMenu, animated: true, completion: nil)
    }
    
    private func toListTapped() {
        let listVC = MainListVC()
        listVC.delegate = self
        listVC.viewModel = MainListViewModel(stations: viewModel.stations)
        listVC.infoView.fetch(geoCode: viewModel.addressString)
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    private func toFavoriteTapped() {
        let tabbar = FavoriteCustomTabbarController()
        navigationController?.pushViewController(tabbar, animated: true)
    }
    
    private func researchStation(with coordinate: CLLocationCoordinate2D? = nil) {
        var centerLocation = CLLocation(latitude: mapContainerView.mapView.latitude, longitude: mapContainerView.mapView.longitude)
        
        if let coordinate {
            centerLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        }
        
        mapContainerView.searchView.placeholderLabel.text = "주유소 위치를 검색해보세요."
        mapContainerView.searchView.placeholderLabel.textColor = .systemGray3
        mapContainerView.searchView.searchImageView.tintColor = .systemGray3
        
        viewModel.requestLocation = centerLocation
        viewModel.selectedStation = nil
        reset()
        mapContainerView.resetInfoWindows()
        viewModel.input.requestStaions.accept(nil)
        viewModel.cameraPosition = nil
        
        fpc.move(to: .hidden, animated: false) { [weak self] in
            guard let self else { return }
            
            self.mapContainerView.researchButton.alpha = 0.0
            self.mapContainerView.researchButton.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide)
            }
        }
    }
    
    private func touchedFavoriteButton() {
        let event = "didTapFavoriteButton"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = viewModel.selectedStation?.id, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
        
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
            }
            return
        }
        var newFaovorites = faovorites
        isDeleted ? newFaovorites = newFaovorites.filter { $0 != _id } : newFaovorites.append(_id)
        
        DefaultData.shared.favoriteSubject.send(newFaovorites)
        updateFavoriteUI()
        
        let msg = isDeleted ? "즐겨 찾는 주유소가 삭제되었습니다." : "즐겨 찾는 주유소에 추가되었습니다."
        let lbl = Preferences.showToast(width: 240, message: msg, numberOfLines: 1)
        view.hideToast()
        view.showToast(lbl, position: .top)
    }
    
    private func toNavigationTapped() {
        let event = "tap_main_navigation"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        requestDirection(station: viewModel.selectedStation)
    }
    
    private func reset() {
        mapContainerView.selectedMarker?.isSelected = false
        mapContainerView.selectedMarker = nil
    }
    
    private func appVersionCheck() {
        ref = Database.database().reference()
        guard let _ref = ref else { return }
        
        let data = _ref.child("version")
        
        data.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let versionData = snapshot.value as? NSDictionary,
                  let versionDic = versionData as? [String: String],
                  let lastest_version_code = versionDic["lastest_version_code"],
                  let lastest_version_name = versionDic["lastest_version_name"],
                  let minimum_version_code = versionDic["minimum_version_code"],
                  let minimum_version_name = versionDic["minimum_version_name"]
            else { return }
            
            let versionDbData = DbVersionData(lastest_version_code: lastest_version_code,
                                              lastest_version_name: lastest_version_name,
                                              minimum_version_code: minimum_version_code,
                                              minimum_version_name: minimum_version_name)
            
            self?.checkUpdateVersion(dbdata: versionDbData)
        })
    }
    
    private func makeRadiusCircle(location: CLLocation?) -> NMFCircleOverlay? {
        guard let _location = location else { return nil }
        let center = NMGLatLng(from: _location.coordinate)
        
        let circle = NMFCircleOverlay(center, radius: 5000.0, fill: .clear)
        circle.outlineColor = .systemBlue
        circle.outlineWidth = 1
        return circle
    }
    
    private func bottomAnimation(state: FloatingPanelState) {
        guard (state == .hidden && bottomOffset != 36.0) ||
                ((state == .half || state == .full) && bottomOffset != 192.0) else { return }
        
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
        
        bottomOffset = state == .hidden ? 36.0 : 192.0
        
        let resultBottomOffset = bottomOffset + view.safeAreaInsets.bottom
        
        animator.addAnimations {
            self.mapContainerView.toFavoriteButton.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-resultBottomOffset)
            }
            self.mapContainerView.currentLocationButton.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-resultBottomOffset)
            }
            
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
    
    @objc
    private func toSearchVC() {
        let searchVC = SearchBarVC()
        searchVC.delegate = self
        navigationController?.pushViewController(searchVC, animated: true)
    }
}

//MARK: - Search 관련
extension MainVC: SearchBarDelegate {
    func fetch(name: String?, coordinate: CLLocationCoordinate2D?) {
        guard let name, let coordinate else { return }
        
        mapContainerView.moveMap(with: coordinate)
        researchStation(with: coordinate)
        
        mapContainerView.searchView.placeholderLabel.text = name
        mapContainerView.searchView.placeholderLabel.textColor = .black
        mapContainerView.searchView.searchImageView.tintColor = .black
    }
}

//MARK: - NaverMap 관련
extension MainVC: MainMapViewDelegate {
    func marker(didTapMarker: NMGLatLng, info: GasStation) {
        if fpc.state == .hidden { fpc.move(to: .half, animated: true, completion: nil) }
        
        contentsVC.stationInfoView.configure(info)
        viewModel.selectedStation = info
        
        let distance = info.distance < 1000 ? "\(Int(info.distance))m" : String(format: "%.1fkm", info.distance / 1000)
        guideView.directionButton.setTitle(distance + " 안내시작", for: .normal)
        guideView.directionButton.setTitle(distance + " 안내시작", for: .highlighted)
    }
}

extension MainVC: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard animated && reason == -1 else { return }
        
        let centerLocation = CLLocation(latitude: mapView.latitude, longitude: mapView.longitude)
        guard let distance = viewModel.requestLocation?.distance(from: centerLocation), distance > 2000 else { return }
        
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
        
        animator.addAnimations {
            self.mapContainerView.researchButton.alpha = 1.0
            self.mapContainerView.researchButton.snp.updateConstraints {
                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(68)
            }
            
            self.view.layoutIfNeeded()
        }
        
        animator.startAnimation()
    }
}

extension MainVC: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        guard fpc.state != .hidden else { return }
        reset()
        viewModel.beforeNAfter.before = .hidden
        fpc.move(to: .hidden, animated: true, completion: nil)
    }
}

//MARK: - FloatingPanel 관련
extension MainVC: FloatingPanelControllerDelegate {
    func setupView() {
        fpc.contentMode = .fitToBounds
        fpc.changePanelStyle() // panel 스타일 변경 (대신 bar UI가 사라지므로 따로 넣어주어야함)
        fpc.delegate = self
        fpc.set(contentViewController: contentsVC) // floating panel에 삽입할 것
        fpc.addPanel(toParent: self) // fpc를 관리하는 UIViewController
        fpc.layout = MyFloatingPanelLayout()
        fpc.invalidateLayout() // if needed
        fpc.show()
    }
    
    //MARK: Delegate
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        return MyFloatingPanelLayout()
    }
    
    func floatingPanelWillBeginDragging(_ fpc: FloatingPanelController) {
        viewModel.beforeNAfter = (fpc.state, viewModel.beforeNAfter.after)
        
        guard fpc.state == .half else { return }
        viewModel.cameraPosition = mapContainerView.mapView.cameraPosition
    }
    
    func isZoomInStation(isHidden: Bool) {
        guideView.isHidden = fpc.state == .hidden
        emptyView.isHidden = fpc.state == .hidden
        mapContainerView.plusView.isHidden = isHidden
        mapContainerView.searchView.isHidden = isHidden
        mapContainerView.researchButton.isHidden = isHidden
        mapContainerView.toFavoriteButton.isHidden = isHidden
        mapContainerView.currentLocationButton.isHidden = isHidden
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        bottomAnimation(state: fpc.state)
        isZoomInStation(isHidden: fpc.state == .full)
        
        let halfHeight = view.safeAreaInsets.bottom + 180.0
        let fullHeight = view.safeAreaInsets.bottom + 422.0
        mapContainerView.mapView.contentInset.bottom = fpc.state == .hidden ? .zero : fpc.state == .half ? halfHeight : fullHeight
        
        switch fpc.state {
        case .hidden:
            reset()
        case .half:
            guard viewModel.beforeNAfter.before == .full, let position = viewModel.cameraPosition else { return }
            let update = NMFCameraUpdate(position: position)
            update.animation = .easeIn
            mapContainerView.mapView.moveCamera(update)
        case .full:
            if let station = viewModel.selectedStation {
                let position = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
                let cameraUpdated = NMFCameraUpdate(position: NMFCameraPosition.init(position, zoom: 15.0))
                cameraUpdated.animation = .linear
                mapContainerView.mapView.moveCamera(cameraUpdated)
            }
            
            guard let station = viewModel.selectedStation, station.id != contentsVC.station?.id else { return }
            
            viewModel.requestStationsInfo(id: station.id) { [weak self] result in
                guard let self = self else { return }
                
                switch result {
                case .success(let resp):
                    guard let ret = try? resp.map(InformationOilStationResult.self),
                          let information = ret.result?.allPriceList?.first else { return }
                    self.contentsVC.station = information
                case .failure(let error):
                    LogUtil.e(error)
                }
            }
        default:
            break
        }
    }
}

//MARK: - List 관련
extension MainVC: MainListVCDelegate {
    func touchedCell(info: GasStation) {
        let position = NMGTm128(x: info.katecX, y: info.katecY).toLatLng()
        marker(didTapMarker: position, info: info)
        
        mapContainerView.selectedMarker = mapContainerView.markers.first(where: {
            guard let station = $0.userInfo["station"] as? GasStation else { return false }
            return station.id == info.id
        })
        mapContainerView.selectedMarker?.isSelected = true
        let update = NMFCameraUpdate(scrollTo: position, zoomTo: 15.0)
        update.animation = .easeIn
        mapContainerView.mapView.moveCamera(update)
        
        self.mapContainerView.researchButton.alpha = 0.0
        mapContainerView.researchButton.snp.updateConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
        }
    }
}

