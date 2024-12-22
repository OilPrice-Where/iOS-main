//
//  SearchNavigation.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum SearchNavigation: String, CaseIterable {
    case kakao = "kakao"
    case kakaoMap = "kakaoMap"
    case tMap = "tMap"
    case naver = "naverMap"
}


extension SearchNavigation {
    /// 네비게이션 타입
    var type: String {
        self.rawValue
    }
    
    /// 네비게이션 `DisplayName`
    var displayName: String {
        switch self {
        case .kakao:
            return "카카오내비"
        case .kakaoMap:
            return "카카오맵"
        case .tMap:
            return "티맵"
        case .naver:
            return "네이버지도"
        }
    }
}
