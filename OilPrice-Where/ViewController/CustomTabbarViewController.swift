//
//  CustomTabbarViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SCLAlertView

class CustomTabbarViewController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
    }
    
    func setupStyle() {
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .systemGray, alpha: 0.2, x: 0, y: 0, blur: 12)
    }
}
