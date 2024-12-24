//
//  AverageCostUseCase.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Combine
import Foundation


protocol AverageCostUseCase {
    /// 선택한 유가 정보
    func fetchAverageCost(for cost: AverageCostType) async -> AverageCost
    /// 전체 유종 평균 유가 데이터
    func updateAverageCosts() -> AnyPublisher<[AverageCost], Never>
}


final class AverageCostUseCaseImpl: AverageCostUseCase {
    
    private let averageCostRepository: AverageCostRepository
    
    init(averageCostRepository: AverageCostRepository) {
        self.averageCostRepository = averageCostRepository
    }
    
    func fetchAverageCost(for cost: AverageCostType) async -> AverageCost {
        let averageCost = try? await averageCostRepository.fetchAverageCost(for: cost.rawValue)
        
        return AverageCost(
            type: cost,
            price: averageCost?[Constants.Parameters.price] as? String ?? "가격 정보 없음",
            isPriceIncreased: averageCost?[Constants.Parameters.difference] as? Bool ?? true
        )
    }
    
    func updateAverageCosts() -> AnyPublisher<[AverageCost], Never> {
        Deferred {
            Future { [weak self] promise in
                guard let self else {
                    return
                }
                
                Task {
                    let costs = await self.fetchAverageCosts()
                    promise(.success(costs))
                }
            }
        }.eraseToAnyPublisher()
    }
}


private extension AverageCostUseCaseImpl {
    enum Constants {
        enum Parameters {
            static let price: String = "price"
            static let difference: String = "difference"
        }
    }
    
    func fetchAverageCosts() async -> [AverageCost] {
        let costs = await withTaskGroup(of: AverageCost.self) { [weak self] group in
            guard let self else {
                return [AverageCost]()
            }
            
            let costTypes = AverageCostType.allCases
            
            for costType in costTypes {
                group.addTask {
                    let cost = await self.fetchAverageCost(for: costType)
                    return cost
                }
            }
            
            var results = [AverageCost]()
            for await cost in group {
                results.append(cost)
            }
            
            return results
        }
        
        return costs
    }
}
