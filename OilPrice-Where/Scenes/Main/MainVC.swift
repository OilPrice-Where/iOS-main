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
import FloatingPanel
//MARK: Main Map VC
final class MainVC: CommonViewController {
    //MARK: - Properties
    let viewModel = MainViewModel()
    private let locationManager = CLLocationManager()
    private lazy var fpc = FloatingPanelController()
    private lazy var contentsVC = StationInfoVC() // 띄울 VC
    private lazy var mapContainerView = MainMapView()
    private lazy var guideView = StationInfoGuideView()
    let emptyView = UIView().then {
        $0.backgroundColor = .white
    }
    lazy var sideMenu = SideMenuNavigationController(rootViewController: MenuVC()).then {
        var set = SideMenuSettings()
        set.statusBarEndAlpha = 0
        set.presentationStyle = SideMenuPresentationStyle.menuSlideIn
        set.presentationStyle.presentingEndAlpha = 0.65
        set.menuWidth = UIScreen.main.bounds.width * (240 / 375)
        set.blurEffectStyle = nil
        $0.leftSide = true
        $0.settings = set
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configure()
        rxBind()
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
        mapContainerView.menuButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.equalToSuperview().offset(20)
            $0.size.equalTo(42)
        }
        mapContainerView.toListButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(42)
        }
        mapContainerView.toFavoriteButton.snp.makeConstraints {
            $0.top.equalTo(mapContainerView.toListButton.snp.bottom).offset(15)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(42)
        }
        mapContainerView.currentLocationButton.snp.makeConstraints {
            $0.top.equalTo(mapContainerView.toFavoriteButton.snp.bottom).offset(15)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(42)
        }
        mapContainerView.researchButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalTo(mapContainerView.snp.centerX)
            $0.width.equalTo(100)
            $0.height.equalTo(42)
        }
        guideView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(70)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(guideView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        
        guideView.addShadow(offset: CGSize(width: 0, height: 4), color: .black, opacity: 0.18, radius: 6.0)
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
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    //MARK: - Rx Binding..
    private func rxBind() {
        DefaultData.shared.completedRelay
            .subscribe(with: self, onNext: { owner, key in
                guard !(key == "Favorites" || key == "LocalFavorites") else {
                    owner.updateFavoriteUI()
                    return
                }
                
                owner.reset()
                DispatchQueue.main.async {
                    owner.fpc.move(to: .hidden, animated: false, completion: nil)
                }
            })
            .disposed(by: rx.disposeBag)
        
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last }
            .subscribe(with: self, onNext: { owner, location in
                owner.viewModel.currentLocation = location
                
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
            .toListButton
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
            .compactMap { self.viewModel.currentLocation }
            .bind(to: mapContainerView.mapView.rx.center)
            .disposed(by: rx.disposeBag)
        
        viewModel.output.staionResult
            .bind(with: self, onNext: { owner, _ in
                owner.mapContainerView.showMarker(list: owner.viewModel.stations)
                NotificationCenter.default.post(name: NSNotification.Name("stationsUpdated"),
                                                object: nil,
                                                userInfo: ["stations": owner.viewModel.stations])
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
            self?.viewModel.currentLocation = nil
            self?.reset()
            self?.mapContainerView.resetInfoWindows()
            self?.fpc.move(to: .hidden, animated: false, completion: nil)
        }
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
        let favoriteVC = FavoritesGasStationVC()
        navigationController?.pushViewController(favoriteVC, animated: true)
    }
    
    private func researchStation() {
        let centerLocation = CLLocation(latitude: mapContainerView.mapView.latitude, longitude: mapContainerView.mapView.longitude)
        
        viewModel.requestLocation = centerLocation
        viewModel.selectedStation = nil
        reset()
        mapContainerView.resetInfoWindows()
        viewModel.input.requestStaions.accept(nil)
        
        fpc.move(to: .hidden, animated: false) { [weak self] in
            self?.mapContainerView.researchButton.isEnabled = false
            self?.mapContainerView.researchButton.alpha = 0.0
        }
    }
    
    private func touchedFavoriteButton() {
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
        
        DefaultData.shared.favoriteSubject.accept(newFaovorites)
        updateFavoriteUI()
    }
    
    private func toNavigationTapped() {
        requestDirection(station: viewModel.selectedStation)
    }
    
    private func reset() {
        mapContainerView.selectedMarker?.isSelected = false
        mapContainerView.selectedMarker = nil
    }
}

// MARK: - CLLocationManagerDelegate
extension MainVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, // 위치 관리자가 위치를 얻을 수 없을 때
                         didFailWithError error: Error) {
        print("did Fail With Error \(error)")
        
        // CLError.locationUnknown: 현재 위치를 알 수 없는데 Core Location이 계속 위치 정보를 요청할 때
        // CLError.denied: 사용자가 위치 서비스를 사용하기 위한 앱 권한을 거부
        // CLError.network: 네트워크 관련 오류
        if (error as NSError).code == CLError.locationUnknown.rawValue {
            return
        }
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            requestLocationAlert()
        default:
            break
        }
    }
    
    // 인증 상태가 변경 되었을 때
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            requestLocationAlert()
        default:
            break
        }
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
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let centerLocation = CLLocation(latitude: mapView.latitude, longitude: mapView.longitude)
        
        guard let distance = viewModel.requestLocation?.distance(from: centerLocation), distance > 2000 else { return }
        
        DispatchQueue.main.async { [weak self] in
            self?.mapContainerView.researchButton.isEnabled = true
            UIView.animate(withDuration: 0.15) {
                self?.mapContainerView.researchButton.alpha = 1.0
            }
        }
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
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        guideView.isHidden = fpc.state == .hidden
        emptyView.isHidden = fpc.state == .hidden
        mapContainerView.menuButton.isHidden = fpc.state == .full
        mapContainerView.toListButton.isHidden = fpc.state == .full
        mapContainerView.researchButton.isHidden = fpc.state == .full
        mapContainerView.toFavoriteButton.isHidden = fpc.state == .full
        mapContainerView.currentLocationButton.isHidden = fpc.state == .full
        
        let halfHeight = view.safeAreaInsets.bottom + 168.0
        let fullHeight = view.safeAreaInsets.bottom + 401.0
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
                    print(error)
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
        mapContainerView.researchButton.isEnabled = false
        mapContainerView.researchButton.alpha = 0.0
    }
}
