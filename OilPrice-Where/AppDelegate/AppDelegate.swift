////
////  AppDelegate.swift
////  OilPrice-Where
////
////  Created by 박상욱 on 2018. 7. 11..
////  Copyright © 2018년 sangwook park. All rights reserved.
////
//
//import UIKit
//import CoreData
//import Firebase
//import FirebaseCore
//import KakaoSDKCommon
//
//@main
//class AppDelegate: UIResponder, UIApplicationDelegate {
//    
//    let firebaseUtility = FirebaseUtility()
//    
//    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//        FirebaseApp.configure()
//        firebaseUtility.checkUpdateTime()
//        
//        #if DEBUG
//        var newArguments = ProcessInfo.processInfo.arguments
//        newArguments.append("-FIRDebugEnabled")
//        ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
//        #endif
//        
//        DataManager.shared.fetchData()
//        KakaoSDK.initSDK(appKey: "b8e7f9ac5bf3c19414515867205f92aa")
//        DefaultData.shared.allPriceDataLoad() // 전국의 오일종류 별 저번주의 평균 값을 받아온다.
//        
//        if #available(iOS 16.1, *),
//           DefaultData.shared.backgroundFindSubject.value {
//            ActivityManager.shared.configure()
//        }
//        
//        return true
//    }
//}
//
