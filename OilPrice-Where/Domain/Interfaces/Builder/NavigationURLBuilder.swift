//
//  NavigationURLBuilder.swift
//  OilPrice-Where
//
//  Created by wargi on 1/28/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


/// 네비게이션 URL을 생성하는 프로토콜
protocol NavigationURLBuilder {
    /// 네비게이션 앱 설치 URL을 반환합니다.
    func installURL() -> URL?
    /// 특정 목적지로 이동하는 네비게이션 URL을 반환합니다.
    /// - Parameters:
    ///   - name: 목적지 이름
    ///   - coordinate: 목적지 좌표
    func destinationURL(name: String, coordinate: CoordinateSystem) -> URL?
}
