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
        configureVC()
        configureTabbar()
    }
    
    func configureVC() {
        let mainVC = MainVC()
        let favoriteVC = FavoritesGasStationVC()
        let settingVC = SettingVC()
        let settingNavigationVC = UINavigationController(rootViewController: settingVC)
        
        mainVC.title = "주유 정보"
        favoriteVC.title = "즐겨찾기"
        settingVC.title = "설정"
        
        setViewControllers([mainVC, favoriteVC, settingNavigationVC], animated: false)
    }
    
    func configureTabbar() {
        guard let tabbarOilInfo = tabBar.items?.first,
              let tabbarFavorite = tabBar.items?[1],
              let tabbarSetting = tabBar.items?.last else { return }
        
        tabbarOilInfo.image = Asset.Images.oilTabIcon.image
        tabbarOilInfo.selectedImage = Asset.Images.oilTabIconSel.image
        
        tabbarFavorite.image = Asset.Images.favoriteTabIcon.image
        tabbarFavorite.selectedImage = Asset.Images.favoriteTabIconSel.image
        
        tabbarSetting.image = Asset.Images.settingTabIcon.image
        tabbarSetting.selectedImage = Asset.Images.settingTabIconSel.image
    }
    
    func setupStyle() {
        UITabBar.clearShadow()
        tabBar.layer.applyShadow(color: .systemGray, alpha: 0.2, x: 0, y: 0, blur: 12)
    }
}
