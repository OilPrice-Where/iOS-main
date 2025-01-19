//
//  SearchPathRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol SearchPathRepository {
    /// 키워드와 관련된 주소 정보를 조회
    func requestFindAllPOIs(keyword: String, count: Int) async -> [SearchPOI]
    /// 유저 주소 조회
    func reverseGeocoding(coordinate: CoordinateSystem) async -> String
}
