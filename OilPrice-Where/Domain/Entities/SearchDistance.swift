//
//  SearchDistance.swift
//  OilPrice-Where
//
//  Created by wargi on 1/23/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum SearchDistance: Int, CaseIterable {
    /// 1KM
    case one = 1000
    /// 3KM
    case three = 3000
    /// 5KM
    case five = 5000
    
    /// String으로 표현된 거리를 기반으로 Distance enum 인스턴스 생성
    init(kmString: String) {
        self = SearchDistance.allCases.first(where: {
            $0.kmString.uppercased() == kmString.uppercased()
        }) ?? .five
    }
}


extension SearchDistance {
    /// 미터 값 반환(`Int`)
    var meters: Int {
        self.rawValue
    }
    
    /// 거리 값을 "1KM", "3KM", "5KM"와 같이 반환
    var kmString: String {
        switch self {
        case .one:
            return "1KM"
        case .three:
            return "3KM"
        case .five:
            return "5KM"
        }
    }
}
