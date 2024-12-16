//
//  HistoriesViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Combine
import Foundation


final class HistoriesViewModel {
    private var cancellable = Set<AnyCancellable>()
}



extension HistoriesViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let swipeToDelete: AnyPublisher<VisitedGasStation, Never>
        let didSelectItem: AnyPublisher<VisitedGasStation, Never>
        let alertConfirmationPublisher: AnyPublisher<VisitedGasStation, Never>
    }
    
    struct Output {
        let presentNavigationAlert: AnyPublisher<VisitedGasStation, Never>
        let moveNavigation: AnyPublisher<URL, Never>
    }
    
    func trasform(input: Input) -> Output {
        input.swipeToDelete
            .sink { [weak self] visitedStation in
                self?.remove(visitedStation: visitedStation)
            }
            .store(in: &cancellable)
            
        let presentNavigationAlert = input.didSelectItem.eraseToAnyPublisher()
        
        let moveNavigation: AnyPublisher<URL, Never> = input.alertConfirmationPublisher
            .compactMap { [weak self] visitedStation in
                guard let self else { return nil }
                save(visitedStation: visitedStation)
                return nil
            }
            .eraseToAnyPublisher()
        
        return .init(
            presentNavigationAlert: presentNavigationAlert,
            moveNavigation: moveNavigation
        )
    }
}

private extension HistoriesViewModel {
    func remove(visitedStation station: VisitedGasStation) {
        
    }
    
    func save(visitedStation station: VisitedGasStation) {
        
    }
}
