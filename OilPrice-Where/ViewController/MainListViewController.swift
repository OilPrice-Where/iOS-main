//
//  ViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation

class MainListViewController: UIViewController {

    @IBOutlet private weak var tableView : UITableView!
    
    let appDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        //Navigation Bar 색상 설정
        UINavigationBar.appearance().barTintColor = self.view.backgroundColor
        
        appDelegate.mainViewController = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("HI02")
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("HI03")
        configureLocationServices()
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
                self.tableView.reloadData()
            case .error(let error):
                print(error)
                
            }
        }
    }
    
    // 위치 관련 인증 확인
    func configureLocationServices() {
        locationManager.delegate = self
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
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    // 위치 검색 중지
    func stopLocationManager() {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
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
        print("Bye")
        let newLocation = locations.last
        
        if newLocation != nil {
            let katecPoint = Converter.convertWGS84ToKatec(coordinate: newLocation!.coordinate)
            
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let stationCount = DefaultData.shared.data?.count else { return 0 }
        return stationCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gasStations = DefaultData.shared.data else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "GasStationCell") as! GasStationCell
        
        cell.configure(with: gasStations[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 145
    }
}

extension MainListViewController: UITableViewDelegate {
    
}
