//
//  AppUpdateStatus.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum AppUpdateStatus {
    /// 최신 버전
    case upToDate(title: String, message: String)
    /// 선택적으로 업데이트할 수 있는 상태
    case optionalUpdate(title: String, message: String, appURL: String)
    /// 반드시 업데이트해야 하는 상태
    case forcedUpdate(title: String, message: String, appURL: String)
    /// 버전 정보를 가져올 수 없는 상태
    case versionInfoUnavailable(title: String, message: String)
}
