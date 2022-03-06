//
//  UIViewController+.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/08.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Foundation
import SCLAlertView

extension UIViewController {
    func makeAlert(title: String, subTitle: String, duration: TimeInterval = 1.5, completion: @escaping SCLAlertView.SCLTimeoutConfiguration.ActionType = {}) {
        let appearance = SCLAlertView.SCLAppearance(kWindowWidth: 300,
                                                    kTitleFont: FontFamily.NanumSquareRound.bold.font(size: 18),
                                                    kTextFont: FontFamily.NanumSquareRound.regular.font(size: 15),
                                                    showCloseButton: false)
        
        let alert = SCLAlertView(appearance: appearance)
        alert.iconTintColor = UIColor.white
        let timeOut = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: duration, timeoutAction: completion)
        
        alert.showWarning(title, subTitle: subTitle, timeout: timeOut, colorStyle: 0x5E82FF)
    }
}
