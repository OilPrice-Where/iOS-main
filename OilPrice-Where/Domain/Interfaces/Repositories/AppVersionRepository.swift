//
//  AppVersionRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol AppVersionRepository {
    /// 현재 앱의 버전을 가져옵니다.
    /// - Returns: 현재 앱 버전 정보
    func fetchCurrentAppVersion() async throws -> DatabaseVersionModel
}
