//
//  CommonViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SCLAlertView

class CommonViewController: UIViewController {
    
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
}
