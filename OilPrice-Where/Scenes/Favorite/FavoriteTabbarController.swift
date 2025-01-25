//
//  FavoriteTabbarController.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then


final class FavoriteTabbarController: UITabBarController {
    //MARK: - Initializer
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setControllers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
}


private extension FavoriteTabbarController {
    enum UIConstants {
        enum Navigation {
            static let title: String = "자주 가는 주유소"
            static let barTintColor: UIColor = .white
            static let barBackgroundColor: UIColor = Asset.Colors.mainColor.color
            static let barTitleTextAttributes: [NSAttributedString.Key : Any] = [
                .font: FontFamily.NanumSquareRound.bold.font(size: 17),
                .foregroundColor: UIColor.white
            ]
        }
        
        enum FavoriteStationsVC {
            static let title: String = "즐겨찾기"
            static let tabImage: UIImage = Asset.Images.favoriteTabIcon.image
            static let tabSelectedImage: UIImage = Asset.Images.favoriteTabIconSel.image
        }
        
        enum FrequentVisitVC {
            static let title: String = "자주가는"
            static let tabImage: UIImage = Asset.Images.oilTabIcon.image
            static let tabSelectedImage: UIImage = Asset.Images.oilTabIconSel.image
        }
    }
    
    func makeUI() {
        configureUI()
    }
    
    func setControllers() {
        viewControllers = [
            makeFavoriteStationsVC(),
            makeFrequentVisitVC()
        ]
    }
    
    func configureUI() {
        tabBar.backgroundColor = .white
        tabBar.tintColor = Asset.Colors.mainColor.color
        tabBar.unselectedItemTintColor = .gray
    }
    
    func updateUI() {
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = UIConstants.Navigation.barBackgroundColor
        
        if let title, title.isEmpty {
            navigationItem.title = UIConstants.Navigation.title
            navigationController?.navigationBar.tintColor = UIConstants.Navigation.barTintColor
            navigationController?.navigationBar.backgroundColor = UIConstants.Navigation.barBackgroundColor
            navigationController?.navigationBar.titleTextAttributes = UIConstants.Navigation.barTitleTextAttributes
        }
    }
    
    func makeFavoriteStationsVC() -> FavoriteStationsVC {
        let settingStorage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
        let stationRepository: StationRepository = StationRepositoryImpl()
        let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
        let favoriteStationsViewModel = FavoriteStationsViewModel(
            settingUseCase: settingUseCase,
            stationRepository: stationRepository,
            visitedStationStorage: visitedStationStorage
        )
        return .init(viewModel: favoriteStationsViewModel).then {
            $0.tabBarItem.title = UIConstants.FavoriteStationsVC.title
            $0.tabBarItem.image = UIConstants.FavoriteStationsVC.tabImage
            $0.tabBarItem.selectedImage = UIConstants.FavoriteStationsVC.tabSelectedImage
        }
    }
    
    func makeFrequentVisitVC() -> FrequentVisitVC {
        let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
        let settingStorage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
        let frequentVisitViewModel = FrequentVisitViewModel(
            storage: visitedStationStorage,
            settingUseCase: settingUseCase
        )
        return .init(viewModel: frequentVisitViewModel).then {
            $0.tabBarItem.title = UIConstants.FrequentVisitVC.title
            $0.tabBarItem.image = UIConstants.FrequentVisitVC.tabImage
            $0.tabBarItem.selectedImage = UIConstants.FrequentVisitVC.tabSelectedImage
        }
    }
}
