//
//  CommonViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CoreLocation
import NMapsMap
import KakaoSDKNavi


class CommonViewController: UIViewController {
    var cancellable = Set<AnyCancellable>()
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
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        LogUtil.d(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNetworkSetting() {
        do {
            try reachability?.startNotifier()
        } catch {
            LogUtil.e(error.localizedDescription)
        }
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
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url,
                                          options: [:],
                                          completionHandler: nil)
            }
        }
        
        alert.addAction(cancelAction)
        alert.addAction(openAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: 버전 체크
    func checkUpdateVersion(versionData data: DatabaseVersionModel) {
        let appLastestVersion = data.latestVersionCode
        let appMinimumVersion = data.minimumVersionCode
        let appLastestVersionName = data.latestVersionName
        let appMinimumVersionName = data.minimumVersionName
        
        guard let infoDic = Bundle.main.infoDictionary,
              let appBuildVersion = infoDic["CFBundleVersion"] as? String,
              let appVersionName = infoDic["CFBundleShortVersionString"] as? String,
              let _appBuildVersion = Int(appBuildVersion),
              let _appMinimumVersion = Int(appMinimumVersion),
              let _appLastestVersion = Int(appLastestVersion) else { return }

        #if RELEASE
        if (appVersionName < appMinimumVersionName) || (appVersionName == appMinimumVersionName && _appBuildVersion < _appMinimumVersion)  {
            forceUdpateAlert()
        } else if appVersionName < appLastestVersionName || (appVersionName == appLastestVersionName && _appBuildVersion < _appLastestVersion) {
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
