//
//  AppDelegate.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Firebase
import FirebaseCore

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let firebaseUtility = FirebaseUtility()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        firebaseUtility.checkUpdateTime()
        
        DefaultData.shared.allPriceDataLoad() // 전국의 오일종류 별 저번주의 평균 값을 받아온다.
        
        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = initialViewController() // 설정페이지 루트뷰 설정
        window?.makeKeyAndVisible()
        
        return true
    }
    
    // initialViewController 초기 설정 페이지 관련 함수
    // 처음 앱을 켰을 때 저장 되어있는 오일 타입이 설정 되어 있지 않을 시에
    // 초기 설정 페이지(InitialSettingViewController)를 루트 뷰로 설정
    // 오일 타입이 있다면 메인 리스트 페이지(TabBarController)를 루트뷰로 설정
    private func initialViewController() -> UIViewController {
        if DefaultData.shared.oilSubject.value != "" {
            return CustomTabbarViewController()
        } else {
            let vc = InitialSettingVC()
            vc.viewModel = InitialViewModel()
            
            return vc
        }
    }
}

