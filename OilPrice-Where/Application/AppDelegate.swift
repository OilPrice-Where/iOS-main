//
//  AppDelegate.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseCore
import KakaoSDKCommon

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        let stationRepository: StationRepository = StationRepositoryImpl()
        let averageCostRepository: AverageCostRepository = FirebaseAverageCostRepository(stationRepository: stationRepository)
        averageCostRepository.checkAndUpdateAverageCosts()
        
        #if DEBUG
        var newArguments = ProcessInfo.processInfo.arguments
        newArguments.append("-FIRDebugEnabled")
        ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
        #endif
        
        KakaoSDK.initSDK(appKey: Preferences.kakaoAppKey())
        
        return true
    }
}

