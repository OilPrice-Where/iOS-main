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
import FloatingPanel
import TMapSDK

final class MainVC: UIViewController {
    let bag = DisposeBag()
    let viewModel = MainViewModel()
    let locationManager = CLLocationManager()
    var fpc = FloatingPanelController()
    var contentsVC = StationInfoVC() // 띄울 VC
    lazy var mapContainerView = MainMapView().then {
        let tap = UITapGestureRecognizer(target: self, action: #selector(toListTapped))
        $0.toListButton.addGestureRecognizer(tap)
        $0.researchButton.addTarget(self, action: #selector(researchStation), for: .touchUpInside)
    }
    let guideView = StationInfoGuideView().then {
        $0.layer.cornerRadius = 6.0
        $0.backgroundColor = .white
        $0.favoriteButton.addTarget(self, action: #selector(touchedFavoriteButton), for: .touchUpInside)
        $0.directionButton.addTarget(self, action: #selector(toNavigationTapped), for: .touchUpInside)
    }
    
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
    func makeUI() {
        view.backgroundColor = .white
        view.addSubview(mapContainerView)
        setupView()
        fpc.view.addSubview(guideView)
        
        mapContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        mapContainerView.toListButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(42)
        }
        mapContainerView.currentLocationButton.snp.makeConstraints {
            $0.top.equalTo(mapContainerView.toListButton.snp.bottom).offset(15)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(42)
        }
        mapContainerView.researchButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.centerX.equalTo(mapContainerView.snp.centerX)
            $0.width.equalTo(130)
            $0.height.equalTo(42)
        }
        guideView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(4)
            $0.height.equalTo(70)
        }
        
        guideView.addShadow(offset: CGSize(width: 0, height: 4), color: .black, opacity: 0.18, radius: 6.0)
    }
    
    func configure() {
        mapContainerView.delegate = self
        mapContainerView.mapView.touchDelegate = self
        mapContainerView.mapView.addCameraDelegate(delegate: self)
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    //MARK: - Rx Binding..
    func rxBind() {
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
                guard let location = owner.viewModel.requestLocation else {
                    owner.mapContainerView.moveMap(with: location.coordinate)
                    owner.viewModel.requestLocation = location
                    owner.viewModel.input.requestStaions.accept(nil)
                    return
                }
                owner.viewModel.currentLocation = location
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
            })
            .disposed(by: viewModel.bag)
        
        // 즐겨찾기 목록의 StationID 값과 StationView의 StationID값이 동일 하면 선택 상태로 변경
        viewModel.output.selectedStation
            .subscribe(with: self, onNext: { owner, _ in
                owner.updateFavoriteUI()
            })
            .disposed(by: rx.disposeBag)
    }
    
    @objc
    func toListTapped() {
        let listVC = MainListVC()
        listVC.delegate = self
        listVC.viewModel = MainListViewModel(stations: viewModel.stations)
        listVC.infoView.fetch(geoCode: viewModel.addressString)
        navigationController?.pushViewController(listVC, animated: true)
    }
    
    @objc
    func researchStation() {
        let centerLocation = CLLocation(latitude: mapContainerView.mapView.latitude, longitude: mapContainerView.mapView.longitude)
        
        viewModel.requestLocation = centerLocation
        viewModel.input.requestStaions.accept(nil)
        
        mapContainerView.researchButton.isEnabled = false
        mapContainerView.researchButton.alpha = 0.0
    }
    
    @objc
    func touchedFavoriteButton() {
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
    
    @objc
    func toNavigationTapped() {
        guard let info = viewModel.selectedStation,
              let type = NaviType(rawValue: DefaultData.shared.naviSubject.value) else { return }
        
        let position = NMGTm128(x: info.katecX, y: info.katecY).toLatLng()
        
        switch type {
        case .tMap:
            if TMapApi.isTmapApplicationInstalled() {
                let _ = TMapApi.invokeRoute(info.name,
                                            coordinate: CLLocationCoordinate2D(latitude: position.lat,
                                                                               longitude: position.lng))
                return
            }
            
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인",
                                         style: .default) { _ in
                guard let url = URL(string: TMapApi.getTMapDownUrl()),
                      UIApplication.shared.canOpenURL(url) else { return }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        case .kakao:
            let destination = KNVLocation(name: info.name,
                                          x: NSNumber(value: info.katecX),
                                          y: NSNumber(value: info.katecY))
            let options = KNVOptions()
            options.routeInfo = false
            let params = KNVParams(destination: destination,
                                   options: options)
            KNVNaviLauncher.shared().navigate(with: params) { [weak self] (error) in
                DispatchQueue.main.async {
                    self?.handleError(error: error)
                }
            }
        case .kakaoMap:
            guard let destinationURL = URL(string: "kakaomap://route?ep=\(position.lat),\(position.lng)&by=CAR"),
            let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/304608425") else { return }
            
            if UIApplication.shared.canOpenURL(destinationURL) {
                UIApplication.shared.open(destinationURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(appstoreURL, options: [:], completionHandler: nil)
            }
        case .naver:
            let urlString = "nmap://navigation?dlat=\(position.lat)&dlng=\(position.lng)&dname=\(info.name)&appname=com.oilpricewhere.wheregasoline"
            
            guard let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let destinationURL = URL(string: encodedStr),
                  let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/311867728") else { return }
            
            if UIApplication.shared.canOpenURL(destinationURL) {
              UIApplication.shared.open(destinationURL)
            } else {
                UIApplication.shared.open(appstoreURL, options: [:], completionHandler: nil)
            }
        }
    }
    
    func updateFavoriteUI() {
        let ids = DefaultData.shared.favoriteSubject.value
        
        guard let id = viewModel.selectedStation?.id else { return }
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        DispatchQueue.main.async { [weak self] in
            self?.guideView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.guideView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
            self?.guideView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
        }
    }
    
    func handleError(error: Error?) {
        guard let error = error as NSError? else { return }
        
        let alert = UIAlertController(title: title,
                                      message: error.localizedFailureReason,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func reset() {
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
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let _ = locations.last else { return }
    }
    
    // 인증 상태가 변경 되었을 때
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
    }
}

//MARK: - Naver MapView 관련
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

extension MainVC: MainListVCDelegate {
    func touchedCell(info: GasStation) {
        let position = NMGTm128(x: info.katecX, y: info.katecY).toLatLng()
        marker(didTapMarker: position, info: info)
        
        mapContainerView.selectedMarker = mapContainerView.markers.first(where: {
            guard let station = $0.userInfo["station"] as? GasStation else { return false }
            return station.id == info.id
        })
        mapContainerView.selectedMarker?.isSelected = true
        mapContainerView.mapView.moveCamera(NMFCameraUpdate(scrollTo: position))
        mapContainerView.researchButton.isEnabled = false
        mapContainerView.researchButton.alpha = 0.0
    }
}

extension MainVC: NMFMapViewCameraDelegate {
    func mapViewCameraIdle(_ mapView: NMFMapView) {
        let centerLocation = CLLocation(latitude: mapView.latitude, longitude: mapView.longitude)
        
        guard let distance = viewModel.requestLocation?.distance(from: centerLocation), distance > 1000 else { return }
        
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
        reset()
        if fpc.state != .hidden { fpc.move(to: .hidden, animated: true, completion: nil) }
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
        viewModel.currentState = fpc.state
    }
    
    func floatingPanelDidMove(_ fpc: FloatingPanelController) {
        print(#function, fpc.state)
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        mapContainerView.toListButton.isHidden = fpc.state == .full
        mapContainerView.currentLocationButton.isHidden = fpc.state == .full
        mapContainerView.researchButton.isHidden = fpc.state == .full
        
        switch fpc.state {
        case .hidden:
            reset()
            guideView.isHidden = true
            mapContainerView.mapView.contentInset.bottom = view.safeAreaInsets.bottom
        case .half:
            guideView.isHidden = false
            mapContainerView.mapView.contentInset.bottom = 168
        case .full:
            guideView.isHidden = false
            mapContainerView.mapView.contentInset.bottom = 401
            
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
                          let information = ret.result.allPriceList.first else { return }
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
