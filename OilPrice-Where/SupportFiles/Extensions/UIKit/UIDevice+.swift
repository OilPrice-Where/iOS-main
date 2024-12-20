//
//  UIDevice+.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit


extension UIDevice {
    /// 기종 확인
    var isiPhoneX: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone &&
            (UIScreen.main.bounds.size.height > 736 || UIScreen.main.bounds.size.width > 414) {
            return true
        }
        return false
    }
}
