//
//  AppNavigationURLBuilder.swift
//  OilPrice-Where
//
//  Created by wargi on 1/28/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import KakaoSDKNavi


struct AppNavigationURLBuilder: NavigationURLBuilder {
    private let settingUseCase: SettingUseCase
    
    init(settingUseCase: SettingUseCase) {
        self.settingUseCase = settingUseCase
    }
    
    func installURL() -> URL? {
        guard let naviType: String = try? settingUseCase.load(type: .navigationType) else {
            return nil
        }
        
        let searchNavigation = SearchNavigation(type: naviType)
        switch searchNavigation {
        case .tMap:
            return AppStoreURLs.tMap
            
        case .kakao:
            return NaviApi.webNaviInstallUrl
            
        case .kakaoMap:
            return AppStoreURLs.kakaoMap
            
        case .naver:
            return AppStoreURLs.naver
        }
    }
    
    func destinationURL(name: String = "방문주유소", coordinate: CoordinateSystem) -> URL? {
        guard let naviType: String = try? settingUseCase.load(type: .navigationType) else {
            return nil
        }
        
        let searchNavigation = SearchNavigation(type: naviType)
        switch searchNavigation {
        case .tMap:
            let urlString = "tmap://?rGoName=\(name)&rGoX=\(coordinate.tm.lng)&rGoY=\(coordinate.tm.lat)"
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return .init(string: encodedStr, encodingInvalidCharacters: false)
            
        case .kakao:
            let destination = NaviLocation(name: name, x: "\(NSNumber(value: coordinate.katec.x))", y: "\(NSNumber(value: coordinate.katec.y))")
            return NaviApi.shared.navigateUrl(destination: destination, option: NaviOption(routeInfo: false))
            
        case .kakaoMap:
            return .init(string: "kakaomap://route?ep=\(coordinate.tm.lat),\(coordinate.tm.lng)&by=CAR", encodingInvalidCharacters: false)
            
        case .naver:
            let urlString = "nmap://navigation?dlat=\(coordinate.tm.lat)&dlng=\(coordinate.tm.lng)&dname=\(name)&appname=com.oilpricewhere.wheregasoline"
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            return .init(string: encodedStr, encodingInvalidCharacters: false)
        }
    }
}


private extension AppNavigationURLBuilder {
    enum AppStoreURLs {
        static let tMap: URL? = .init(string: "itms-apps://itunes.apple.com/app/431589174", encodingInvalidCharacters: false)
        static let kakaoMap: URL? = .init(string: "itms-apps://itunes.apple.com/app/304608425", encodingInvalidCharacters: false)
        static let naver: URL? = .init(string: "itms-apps://itunes.apple.com/app/311867728", encodingInvalidCharacters: false)
    }
}
