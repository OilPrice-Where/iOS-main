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
    
    /// 내비게이션 코드로 인스턴스 생성
    init(type: String) {
        self = SearchNavigation(rawValue: type) ?? .kakaoMap
    }
    
    /// 내비게이션명으로 인스턴스 생성
    init(displayName name: String) {
        self = SearchNavigation.allCases.first(where: { $0.displayName == name }) ?? .kakaoMap
    }
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
