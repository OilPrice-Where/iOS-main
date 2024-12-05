//
//  DBVersionData.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/19.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation


struct DatabaseVersionModel {
    /// 최신 버전 코드
    let latestVersionCode: String
    /// 최신 버전 명
    let latestVersionName: String
    /// 최소 버전 코드
    let minimumVersionCode: String
    /// 최소 버전 명
    let minimumVersionName: String
}
