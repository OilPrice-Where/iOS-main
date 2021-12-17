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
        let favoriteVC = FavoritesGasStationVC()
        let settingVC = SettingVC()
        let settingNavigationVC = UINavigationController(rootViewController: settingVC)
        
        favoriteVC.title = "즐겨찾기"
        settingVC.title = "설정"
        
        var viewControllers = self.viewControllers
        
        viewControllers?.append(contentsOf: [favoriteVC, settingNavigationVC])
        
        setViewControllers(viewControllers, animated: false)
    }
    
    func configureTabbar() {
        guard let tabbarFavorite = tabBar.items?[1],
              let tabbarSetting = tabBar.items?[2] else { return }
        
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
