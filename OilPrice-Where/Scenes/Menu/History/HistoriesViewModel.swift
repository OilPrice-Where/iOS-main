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
    
    private let visitedStationsPublisher: CurrentValueSubject<[HistoryItem], Never> = .init([])
    
    
    init(storage: VisitedStationStorage,
         settingUseCase: SettingUseCase) {
        self.storage = storage
        self.settingUseCase = settingUseCase
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
    }
}


extension HistoriesViewModel {
    struct HistoryItem: Hashable {
        let index: Int
        let station: VisitedGasStation
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let swipeToDelete: AnyPublisher<HistoryItem, Never>
        let didSelectItem: AnyPublisher<HistoryItem, Never>
        let alertConfirmationPublisher: AnyPublisher<HistoryItem, Never>
    }
    
    struct Output {
        let visitStationItems: AnyPublisher<[HistoryItem], Never>
        let presentNavigationAlert: AnyPublisher<HistoryItem, Never>
        let moveNavigation: AnyPublisher<URL, Never>
    }
    
    func trasform(input: Input) -> Output {
        bindActions(input: input)
            
        let presentNavigationAlert = input.didSelectItem.eraseToAnyPublisher()
        
        let moveNavigation: AnyPublisher<URL, Never> = input.alertConfirmationPublisher
            .compactMap { [weak self] historyItem in
                guard let self else {
                    return nil
                }
                
                save(visitedStation: historyItem.station)
                
                let destinationURL = urlBuilder.destinationURL(
                    name: historyItem.station.name,
                    coordinate: historyItem.station.coordinate
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
            visitStationItems: visitedStationsPublisher.eraseToAnyPublisher(),
            presentNavigationAlert: presentNavigationAlert,
            moveNavigation: moveNavigation
        )
    }
    
    func bindActions(input: Input) {
        input.viewDidLoad
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                let historyItems = storage.fetchVisitedStations().enumerated().map { index, station in
                    HistoryItem(
                        index: index,
                        station: station
                    )
                }
                visitedStationsPublisher.send(historyItems)
            }
            .store(in: &cancellable)
        
        input.swipeToDelete
            .sink { [weak self] historyItem in
                self?.remove(visitedStation: historyItem.station)
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
                let historyItems = storage.fetchVisitedStations().enumerated().map { index, station in
                    HistoryItem(
                        index: index,
                        station: station
                    )
                }
                visitedStationsPublisher.send(historyItems)
            } catch {
                LogUtil.e(error.localizedDescription)
            }
        }
    }
}
