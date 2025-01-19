//
//  HistoriesViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import Combine


final class HistoriesViewModel {
    
    private var cancellable = Set<AnyCancellable>()
    
    private let storage: VisitedStationStorage
    private let settingUseCase: SettingUseCase
    private let urlBuilder: NavigationURLBuilder
    
    private(set) var visitedStations: CurrentValueSubject<[VisitedGasStation], Never> = .init([])
    
    
    init(storage: VisitedStationStorage,
         settingUseCase: SettingUseCase) {
        self.storage = storage
        self.settingUseCase = settingUseCase
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
    }
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
        bindActions(input: input)
            
        let presentNavigationAlert = input.didSelectItem.eraseToAnyPublisher()
        
        let moveNavigation: AnyPublisher<URL, Never> = input.alertConfirmationPublisher
            .compactMap { [weak self] visitedStation in
                guard let self else {
                    return nil
                }
                
                save(visitedStation: visitedStation)
                
                let destinationURL = urlBuilder.destinationURL(
                    name: visitedStation.name,
                    coordinate: visitedStation.coordinate
                )
                
                if let destinationURL,
                   UIApplication.shared.canOpenURL(destinationURL) {
                    return destinationURL
                } else {
                    return urlBuilder.installURL()
                }
            }
            .eraseToAnyPublisher()
        
        return .init(
            presentNavigationAlert: presentNavigationAlert,
            moveNavigation: moveNavigation
        )
    }
    
    func bindActions(input: Input) {
        input.viewDidLoad
            .sink { [weak self] _ in
                let visitedStations = self?.storage.fetchVisitedStations() ?? []
                self?.visitedStations.send(visitedStations)
            }
            .store(in: &cancellable)
        
        input.swipeToDelete
            .sink { [weak self] visitedStation in
                self?.remove(visitedStation: visitedStation)
            }
            .store(in: &cancellable)
    }
}


private extension HistoriesViewModel {
    func remove(visitedStation station: VisitedGasStation) {
        Task {
            do {
                try await storage.removeVisited(station: station)
            } catch {
                LogUtil.e(error.localizedDescription)
            }
        }
    }
    
    func save(visitedStation station: VisitedGasStation) {
        Task {
            do {
                try await storage.saveVisited(station: station)
                visitedStations.send(storage.fetchVisitedStations())
            } catch {
                LogUtil.e(error.localizedDescription)
            }
        }
    }
}
