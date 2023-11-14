//
//  OilPriceWhereApp.swift
//  OilPrice-Where
//
//  Created by wargi on 1/7/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import ComposableArchitecture
import Firebase
import KakaoSDKCommon

@main
struct OilPriceWhereApp: App {
    
    @Environment(\.scenePhase) private var phase
    
    let store: StoreOf<InitialSettingReducer>
    let firebaseUtility = FirebaseUtility()
    
    init() {
        self.store = Store(initialState: InitialSettingReducer.State(), reducer: {
            InitialSettingReducer()
        })
        
        FirebaseApp.configure()
        firebaseUtility.checkUpdateTime()
        
        #if DEBUG
        var newArguments = ProcessInfo.processInfo.arguments
        newArguments.append("-FIRDebugEnabled")
        ProcessInfo.processInfo.setValue(newArguments, forKey: "arguments")
        #endif

        DataManager.shared.fetchData()
        KakaoSDK.initSDK(appKey: "b8e7f9ac5bf3c19414515867205f92aa")
        DefaultData.shared.allPriceDataLoad() // 전국의 오일종류 별 저번주의 평균 값을 받아온다.

        if #available(iOS 16.1, *),
           DefaultData.shared.backgroundFindSubject.value {
            ActivityManager.shared.configure()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            InitialSettingView(store: self.store)
                .onChange(of: phase) {
                    switch $0 {
                    case .active:
                        UIApplication.shared.applicationIconBadgeNumber = 0
                        
                        if #available(iOS 16.1, *),
                           DefaultData.shared.backgroundFindSubject.value,
                           ActivityManager.shared.activity?.activityState != .active {
                            ActivityManager.shared.configure()
                        }
                    case .background:
                        DataManager.shared.saveContext()
                        
                        guard DefaultData.shared.backgroundFindSubject.value else { return }
                        
                        if #available(iOS 16.1, *) {
                            guard ActivityManager.shared.activity?.activityState == .active else { return }
                            
                            Task {
                                await ActivityManager.shared.endActivities()
                            }
                        }
                    case .inactive:
                        break
                    }
                }
                .onContinueUserActivity("NSUserActivityTypeLiveActivity") { userActivity in
                    guard let navi = UIApplication.shared.customKeyWindow?.visibleViewController?.navigationController else {
                        return
                    }
                    
                    navi.popToRootViewController(animated: true)
                    
                    NotificationCenter.default.post(name: NSNotification.Name("liveActivities"),
                                                    object: nil,
                                                    userInfo: nil)
                }
        }
    }
}
