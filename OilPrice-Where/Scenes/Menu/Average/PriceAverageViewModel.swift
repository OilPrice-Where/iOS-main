//
//  PriceAverageViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Combine
import Foundation


final class PriceAverageViewModel {
    
    private let averageCostUseCase: AverageCostUseCase
    
    init(averageCostUseCase: AverageCostUseCase) {
        self.averageCostUseCase = averageCostUseCase
    }
}


extension PriceAverageViewModel {
    struct Input {
        var viewDidLoad: AnyPublisher<Void, Never>
    }
    
    struct Output {
        var updateAverageCosts: AnyPublisher<[AverageCost], Never>
    }
    
    func transform(input: Input) -> Output {
        let updateAverageCosts = input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<[AverageCost], Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return averageCostUseCase.updateAverageCosts()
            }
            .eraseToAnyPublisher()
        
        return .init(
            updateAverageCosts: updateAverageCosts
        )
    }
}
