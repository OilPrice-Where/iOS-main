//
//  FavoriteCustomTabbarController.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import UIKit

class FavoriteCustomTabbarController: UITabBarController {
    //MARK: - Initializer
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
        
        guard title?.isEmpty ?? true else { return }
        navigationItem.title = "자주 가는 주유소"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
    }
    
    func configure() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = Asset.Colors.mainColor.color
        tabBar.unselectedItemTintColor = .gray
        
        let favoriteVC = FavoritesGasStationVC()
        favoriteVC.tabBarItem.title = "즐겨찾기"
        favoriteVC.tabBarItem.image = Asset.Images.favoriteTabIcon.image
        favoriteVC.tabBarItem.selectedImage = Asset.Images.favoriteTabIconSel.image
        
        let listVC = FrequentVisitVC()
        listVC.tabBarItem.title = "자주가는"
        listVC.tabBarItem.image = Asset.Images.oilTabIcon.image
        listVC.tabBarItem.selectedImage = Asset.Images.oilTabIconSel.image

        viewControllers = [favoriteVC, listVC]
    }
}
