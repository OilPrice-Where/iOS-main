//
//  CommonViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SCLAlertView
import CoreLocation
import NMapsMap
import TMapSDK
import RxSwift

class CommonViewController: UIViewController {
    let bag = DisposeBag()
    var reachability: Reachability? = Reachability() //Network
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setNetworkSetting()
    }
    
    deinit {
        print(self, #function)
        reachability?.stopNotifier()
        reachability = nil
    }
    
    func setNetworkSetting() {
        do {
            try reachability?.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
    }
    
    func makeAlert(title: String,
                   subTitle: String,
                   duration: TimeInterval = 1.5,
                   showCloseButton: Bool = false,
                   closeButtonTitle: String? = nil,
                   colorStyle: UInt = 0x5E82FF,
                   completion: @escaping SCLAlertView.SCLTimeoutConfiguration.ActionType = {}) {
        let appearance = SCLAlertView.SCLAppearance(kWindowWidth: 300,
                                                    kTitleFont: FontFamily.NanumSquareRound.bold.font(size: 18),
                                                    kTextFont: FontFamily.NanumSquareRound.regular.font(size: 15),
                                                    showCloseButton: showCloseButton)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.iconTintColor = UIColor.white
        let timeOut = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: completion)
        
        guard duration == 1.5 else {
            alert.showError(title, subTitle: subTitle, closeButtonTitle: closeButtonTitle, colorStyle: colorStyle)
            return
        }
        alert.showWarning(title, subTitle: subTitle, timeout: timeOut, colorStyle: colorStyle)
    }
    
    func notConnect() {
        makeAlert(title: "네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", duration: 0.0, showCloseButton: true, closeButtonTitle: "확인")
    }
    
    func requestLocationAlert() {
        let alert = UIAlertController(title: "위치정보를 불러올 수 없습니다.",
                                      message: "위치정보를 사용해 주변 주유소의 정보를 불러오기 때문에 위치정보 사용이 꼭 필요합니다. 설정으로 이동하여 위치 정보 접근을 허용해 주세요.",
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "취소",
                                         style: .cancel,
                                         handler: nil)
        
        let openAction = UIAlertAction(title: "설정으로 이동",
                                       style: .default) { _ in
            if let url = URL(string: UIApplicationOpenSettingsURLString) {
                UIApplication.shared.open(url,
                                          options: [:],
                                          completionHandler: nil)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    func requestDirection(station: GasStation?) {
        guard let info = station,
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
    // 길안내 에러 발생
    func handleError(error: Error?) {
        guard let error = error as NSError? else { return }
        
        let alert = UIAlertController(title: title,
                                      message: error.localizedFailureReason,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}
