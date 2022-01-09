//
//  MainVC.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import CoreLocation
import UIKit

final class MainVC: UIViewController {
//    let mainListView = MainListView()
    let mapView = MainMapView()
    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(mapView)
        
        mapView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(view.safeAreaInsets.top)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func configure() {
        locationManager.delegate = self
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
