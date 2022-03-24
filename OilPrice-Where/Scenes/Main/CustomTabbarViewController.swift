//
//  CustomTabbarViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SCLAlertView
//MARK: 메인 탭바
final class CustomTabbarViewController: UITabBarController {
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupStyle()
        configureVC()
        configureTabbar()
    }
    
    //MARK: - Configure
    func configureVC() {
        let mainVC = MainVC()
        let mainNavigationVC = UINavigationController(rootViewController: mainVC)
        let settingVC = SettingVC()
        let settingNavigationVC = UINavigationController(rootViewController: settingVC)
        
        mainVC.title = "주유 정보"
        settingVC.title = "설정"
        
        setViewControllers([mainNavigationVC, settingNavigationVC], animated: false)
    }
    
    func configureTabbar() {
        guard let tabbarOilInfo = tabBar.items?.first,
              let tabbarSetting = tabBar.items?.last else { return }
        
        tabbarOilInfo.image = Asset.Images.oilTabIcon.image
        tabbarOilInfo.selectedImage = Asset.Images.oilTabIconSel.image
        
        tabbarSetting.image = Asset.Images.settingTabIcon.image
        tabbarSetting.selectedImage = Asset.Images.settingTabIconSel.image
    }
    
    func setupStyle() {
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .systemGray, alpha: 0.2, x: 0, y: 0, blur: 12)
        tabBar.layer.shouldRasterize = true
        tabBar.layer.rasterizationScale = UIScreen.main.scale
    }
}
