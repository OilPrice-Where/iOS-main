//
//  AppDelegate.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Firebase
import SwiftyPlistManager

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var mainViewController:MainListViewController?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        
//        var ref: DatabaseReference!
//
//        ref = Database.database().reference()
//        var data = ref.child("test")
//
//        print("**************yy******************")
//        data.observeSingleEvent(of: DataEventType.value, with: { (snapshot) in
//            let tempNum = snapshot.value as! Int
//            print(tempNum, "******************ffff******************")
//        })

        DefaultData.shared.allPriceDataLoad()
        
        // 지연 1초
        sleep(1)
        
        window?.rootViewController = initialViewController()
        
        return true
    }
    
    private func initialViewController() -> UIViewController {
        if DefaultData.shared.oilType == "" {
            return UIStoryboard(name: "Main",
                                bundle: nil).instantiateViewController(withIdentifier: "InitialSettingViewController")
        } else {
            return UIStoryboard(name: "Main",
                                bundle: nil).instantiateViewController(withIdentifier: "MainListViewController")
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        // 앱 백드라운드로 갈 시 설정 데이터 저장
        DefaultData.shared.save()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        mainViewController?.configureLocationServices()
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
        // 앱 종료시 마지막 설정 데이터 저장
        DefaultData.shared.save()
    }


}

