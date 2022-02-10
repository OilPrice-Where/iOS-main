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

final class MainVC: UIViewController {
    let viewModel = MainViewModel()
    let mainListView = MainListView()
    let mapContainerView = MainMapView()
    let locationManager = CLLocationManager()
    var fpc = FloatingPanelController()
    var contentsVC = StationInfoVC() // 띄울 VC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setupView()
        configure()
        rxBind()
    }
    
    func makeUI() {
        view.backgroundColor = .white
        
        view.addSubview(mapContainerView)
        
        mapContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
//        mapContainerView.switchButton.snp.makeConstraints {
//            $0.size.equalTo(50)
//            $0.right.equalToSuperview().offset(-20)
//            $0.bottom.equalTo(fpc.view.snp.top).offset(-12)
//        }
    }
    
    func configure() {
        mapContainerView.delegate = self
        mapContainerView.mapView.touchDelegate = self
        locationManager.delegate = self
        
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func rxBind() {
        locationManager.rx.didUpdateLocations
            .compactMap { $0.last }
            .subscribe(with: self, onNext: { owner, location in
                guard let oldLocation = owner.viewModel.currentLocation else {
                    owner.mapContainerView.moveMap(with: location.coordinate)
                    owner.viewModel.currentLocation = location
                    owner.viewModel.input.requestStaions.accept(nil)
                    return
                }
                
                let distance = abs(location.distance(from: oldLocation))
                if distance > 500 {
                    owner.viewModel.currentLocation = location
                    owner.viewModel.input.requestStaions.accept(nil)
                }
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
            .bind(with: self, onNext: { owner, stations in
                owner.mapContainerView.showMarker(list: stations)
            })
            .disposed(by: viewModel.bag)
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
        guard let newLocation = locations.last else { return }
        
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(newLocation, completionHandler: {
            placemarks, error in
            if let _ = error { return }
            
            var currentPlacemark: CLPlacemark?
            // 에러가 없고, 주소 정보가 있으며 주소가 공백이지 않을 시
            if error == nil, let p = placemarks, !p.isEmpty {
                currentPlacemark = p.last
            } else {
                currentPlacemark = nil
            }

//            self.mainListView.headerView.fetchData(getCode: self.string(from: self.currentPlacemark))
        })
        
//        if let lastLocation = oldLocation {
//            let distance: CLLocationDistance = newLocation.distance(from: lastLocation)
//            if distance < 50.0 {
//                stopLocationManager()
//                mainListView.tableView.reloadData()
//            } else {
//                reset()
//                gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
//                stopLocationManager()
//                oldLocation = newLocation
//                zoomToLatestLocation(with: newLocation.coordinate)
//            }
//        } else {
//            zoomToLatestLocation(with: newLocation.coordinate)
//            gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
//            stopLocationManager()
//            oldLocation = newLocation
//        }

        // 인증 상태가 변경 되었을 때
        func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        }
    }
}

extension MainVC: MainMapViewDelegate {
    func marker(didTapMarker: NMGLatLng, info: GasStation) {
        if fpc.state == .hidden { fpc.move(to: .tip, animated: true, completion: nil) }
        
        contentsVC.stationInfoView.configure(info)
    }
}

extension MainVC: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        mapContainerView.selectedMarker?.isSelected = false
        mapContainerView.selectedMarker = nil
        
        if fpc.state != .hidden { fpc.move(to: .hidden, animated: true, completion: nil) }
    }
}

//MARK: FloatingPanel
extension MainVC: FloatingPanelControllerDelegate {
    func setupView() {
        fpc.contentMode = .fitToBounds
        fpc.changePanelStyle() // panel 스타일 변경 (대신 bar UI가 사라지므로 따로 넣어주어야함)
        fpc.delegate = self
        fpc.set(contentViewController: contentsVC) // floating panel에 삽입할 것
        fpc.addPanel(toParent: self) // fpc를 관리하는 UIViewController
        fpc.layout = MyFloatingPanelLayout()
        fpc.invalidateLayout() // if needed
        fpc.move(to: .tip, animated: false, completion: nil)
    }
    
    //MARK: Delegate
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        return MyFloatingPanelLayout()
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        print(fpc.state)
    }
}
