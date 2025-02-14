//
//  SceneDelegate.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/11/11.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(windowScene: windowScene)
        window?.overrideUserInterfaceStyle = .light
        window?.rootViewController = initialViewController() // 설정페이지 루트뷰 설정
        window?.makeKeyAndVisible()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        DataManager.shared.saveContext()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        guard userActivity.activityType == "NSUserActivityTypeLiveActivity",
              let navi = UIApplication.shared.customKeyWindow?.visibleViewController?.navigationController else { return }
        
        navi.popToRootViewController(animated: true)
        
        NotificationCenter.default.post(name: NSNotification.Name("liveActivities"),
                                        object: nil,
                                        userInfo: nil)
    }
    
    /*
     initialViewController 초기 설정 페이지 관련 함수
     처음 앱을 켰을 때 저장 되어있는 오일 타입이 설정 되어 있지 않을 시에
     초기 설정 페이지(InitialSettingViewController)를 루트 뷰로 설정
     오일 타입이 있다면 메인 리스트 페이지(TabBarController)를 루트뷰로 설정
     */
    private func initialViewController() -> UIViewController {
        let settingStorage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
        let fuelCode: String = settingStorage.fetchValue(
            defaultValue: "",
            forKey: SettingType.fuelType.key,
            fromStorageNamed: PlistSettingStorage.Constants.defaultStorageName)
        
        if fuelCode.isEmpty {
            let initialSettingsViewModel = InitialSettingsViewModel(settingUseCase: settingUseCase)
            let initialSettingsVC = InitialSettingsVC(viewModel: initialSettingsViewModel)
            return initialSettingsVC
        } else {
            let stationRepository: StationRepository = StationRepositoryImpl()
            let stationInfoViewModel: StationInfoViewModel = StationInfoViewModel(
                settingUseCase: settingUseCase,
                stationRepository: stationRepository)
            
            let appVersionRepository: AppVersionRepository = FirebaseAppVersionRepository()
            let appVersionUseCase: AppVersionUseCase = AppVersionUseCaseImpl(appVersionRepository: appVersionRepository)
            let menuViewModel = MenuViewModel(
                settingUseCase: settingUseCase,
                appVersionUseCase: appVersionUseCase)
            
            let mainViewModel = MainViewModel(
                settingUseCase: settingUseCase,
                stationRepository: stationRepository)
            let mainVC = MainVC(
                viewModel: mainViewModel,
                menuViewModel: menuViewModel,
                stationInfoViewModel: stationInfoViewModel
            )
            let mainNavigationVC = UINavigationController(rootViewController: mainVC)
            return mainNavigationVC
        }
    }
}

