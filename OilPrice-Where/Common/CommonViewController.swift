//
//  CommonViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import NMapsMap
import CoreLocation
import Combine
import KakaoSDKNavi

class CommonViewController: UIViewController {
    typealias ResultURL = (isCanOpen: Bool, requestURL: URL?)
    
    let bag = DisposeBag()
    var cancelBag = Set<AnyCancellable>()
    var reachability: Reachability? = Reachability() //Network
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setNetworkSetting()
    }
    
    deinit {
        LogUtil.d(self)
        reachability?.stopNotifier()
        reachability = nil
    }
    
    func setNetworkSetting() {
        do {
            try reachability?.startNotifier()
        } catch {
            LogUtil.e(error.localizedDescription)
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
    
    func requestURL(station: GasStation?) -> ResultURL {
        let dummy = GasStation(id: "", brand: "", name: "Dummy", price: 0, distance: 0.0, katecX: 465535.79052, katecY: 351548.26588)
        guard let type = NaviType(rawValue: DefaultData.shared.naviSubject.value) else { return (false, nil) }
        let info = station ?? dummy
        
        var destinationURL: URL? = nil
        var appstoreURL: URL? = nil
        
        let position = NMGTm128(x: info.katecX, y: info.katecY).toLatLng()
        
        switch type {
        case .tMap:
            let urlString = "tmap://?rGoName=\(info.name)&rGoX=\(position.lng)&rGoY=\(position.lat)"
            
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            destinationURL = URL(string: encodedStr ?? "")
            appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/431589174")
        case .kakao:
            let destination = NaviLocation(name: info.name, x: "\(NSNumber(value: info.katecX))", y: "\(NSNumber(value: info.katecY))")
            destinationURL = NaviApi.shared.navigateUrl(destination: destination, option: NaviOption(routeInfo: false))
            appstoreURL = NaviApi.webNaviInstallUrl
        case .kakaoMap:
            destinationURL = URL(string: "kakaomap://route?ep=\(position.lat),\(position.lng)&by=CAR")
            appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/304608425")
        case .naver:
            let urlString = "nmap://navigation?dlat=\(position.lat)&dlng=\(position.lng)&dname=\(info.name)&appname=com.oilpricewhere.wheregasoline"
            
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            destinationURL = URL(string: encodedStr ?? "")
            appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/311867728")
        }
        
        guard let _destinationURL = destinationURL, let _appstoreURL = appstoreURL else { return (false, nil) }
        
        return UIApplication.shared.canOpenURL(_destinationURL) ? (true, _destinationURL) : (false, _appstoreURL)
    }
    
    func requestDirection(station: GasStation?) {
        guard let info = station,
              let requestURL = requestURL(station: info).requestURL else { return }
        
        DataManager.shared.addNew(station: info)
        
        UIApplication.shared.open(requestURL, options: [:], completionHandler: nil)
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
    
    //MARK: 버전 체크
    func checkUpdateVersion(dbdata: DbVersionData){
        let appLastestVersion = dbdata.lastest_version_code
        let appMinimumVersion = dbdata.minimum_version_code
        let appLastestVersionName = dbdata.lastest_version_name
        let appMinimumVersionName = dbdata.minimum_version_name
        
        guard let infoDic = Bundle.main.infoDictionary,
              let appBuildVersion = infoDic["CFBundleVersion"] as? String,
              let appVersionName = infoDic["CFBundleShortVersionString"] as? String,
              let _appBuildVersion = Int(appBuildVersion),
              let _appMinimumVersion = Int(appMinimumVersion),
              let _appLastestVersion = Int(appLastestVersion) else { return }
        
        #if DEBUG
        return
        #else
        if (appVersionName < appMinimumVersionName) || (appVersionName == appMinimumVersionName && _appBuildVersion < _appMinimumVersion)  {
            forceUdpateAlert()
        } else if appVersionName < dbdata.lastest_version_name || (appVersionName == appLastestVersionName && _appBuildVersion < _appLastestVersion) {
            optionalUpdateAlert(version: _appLastestVersion)
        }
        #endif
    }
    
    func forceUdpateAlert() {
        let msg = "최신 버전의 앱으로 업데이트해주세요."
        let refreshAlert = UIAlertController(title: "업데이트 알림", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { _ in
            let id = "1435350344"
            if let appURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)"),
               UIApplication.shared.canOpenURL(appURL) {
                // 유효한 URL인지 검사
                if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                    UIApplication.shared.open(appURL, options: [:]) { _ in
                        exit(0)
                    }
                } else {
                    UIApplication.shared.openURL(appURL)
                }
            }
        }
        
        refreshAlert.addAction(okAction)
        present(refreshAlert, animated: true, completion: nil)
        
    }
    
    func optionalUpdateAlert(version:Int) {
        let msg = "새로운 버전이 출시되었습니다.\n업데이트를 하지 않는 경우 서비스 이용에 제한이 있을 수 있습니다. 업데이트를 진행하시겠습니까?"
        let refreshAlert = UIAlertController(title: "업데이트", message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "지금 업데이트 하기", style: .default) { _ in
            let id = "1435350344"
            if let appURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)"),
               UIApplication.shared.canOpenURL(appURL) {
                // 유효한 URL인지 검사
                if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(appURL)
                }
            }
        }
        
        let cancelAction = UIAlertAction(title: "나중에 하기", style: .destructive, handler: nil)
        refreshAlert.addAction(cancelAction)
        refreshAlert.addAction(okAction)
        
        present(refreshAlert, animated: true, completion: nil)
    }
}
