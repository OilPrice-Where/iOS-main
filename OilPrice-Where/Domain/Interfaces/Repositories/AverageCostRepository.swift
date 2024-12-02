//
//  AverageCostRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol AverageCostRepository {
    /// 선택한 유가 정보
    func fetchAverageCost(for productName: String) async throws -> NSDictionary
    /// 평균 유가 데이터를 확인 후 업데이트
    func checkAndUpdateAverageCosts()
}
