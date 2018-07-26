//
//  ViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation

struct KatecPoint {
    let x: Double
    let y: Double
}

class MainListViewController: UIViewController {

    @IBOutlet private weak var tableView : UITableView!
    var gasStations: [GasStation]?
    
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var updatingLocation = false
    var lastLocationError: Error?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startLocationManager()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    private func gasStationListData(katecPoint: KatecPoint){
        print(katecPoint) 
        ServiceList.gasStationList(x: katecPoint.x, y: katecPoint.y, radius: 3000, prodcd: "B027", sort: 1) { (result) in
            switch result {
            case .success(let gasStationData):
                print(gasStationData)
                self.gasStations = gasStationData.result.gasStations
                self.tableView.reloadData()
                self.stopLocationManager()
            case .error(let error):
                print(error)
                
            }
        }
    }

    func convertWGS84ToKatec(longitude: Double, latitude: Double) -> KatecPoint {
        let convert = GeoConverter()
        let wgsPoint = GeographicPoint(x: longitude, y: latitude)
        let tmPoint = convert.convert(sourceType: .WGS_84, destinationType: .TM, geoPoint: wgsPoint)
        let katecPoint = convert.convert(sourceType: .TM, destinationType: .KATEC, geoPoint: tmPoint!)
        
        return KatecPoint(x: katecPoint!.x.roundTo(places: 8), y: katecPoint!.y.roundTo(places: 8))
        
    }
    
    // 위치 검색 시작
    func startLocationManager() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters // 정확도 설정
            locationManager.startUpdatingLocation() // 좌표 받기
            updatingLocation = true
        }
    }
    
    // 위치 검색 중지
    func stopLocationManager() {
        if updatingLocation {
            locationManager.stopUpdatingLocation()
            locationManager.delegate = nil
            updatingLocation = false
        }
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
            print(newLocation!.coordinate)
            let katecPoint = convertWGS84ToKatec(longitude: newLocation!.coordinate.longitude,
                                                 latitude: newLocation!.coordinate.latitude)
            
            gasStationListData(katecPoint: KatecPoint(x: katecPoint.x, y: katecPoint.y))
        }
    }
}

// MARK: - UITableView
extension MainListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gasStations?.count ?? 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let gasStations = self.gasStations else {
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
