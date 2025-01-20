//
//  FrequentVisitViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine


//MARK: FrequentVisitViewModel
final class FrequentVisitViewModel {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    private let storage: VisitedStationStorage
    private(set) var settingUseCase: SettingUseCase
    private let urlBuilder: NavigationURLBuilder
    
    private let visitStationsPublisher: CurrentValueSubject<[VisitedGasStation], Never> = .init([])
    private let updateFavoriteButtonPublisher = CurrentValueSubject<Bool, Never>(false)
    
    //MARK: Initializer
    init(storage: VisitedStationStorage,
         settingUseCase: SettingUseCase) {
        self.storage = storage
        self.settingUseCase = settingUseCase
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
    }
}


//MARK: - I/O & transform
extension FrequentVisitViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<VisitedGasStation, Never>
        let didTapDirectionStation: AnyPublisher<VisitedGasStation, Never>
        let didTapFavoriteStation: AnyPublisher<VisitedGasStation, Never>
    }
    
    struct Output {
        let visitedStations: AnyPublisher<[VisitedGasStation], Never>
        let showStationDetail: AnyPublisher<UIViewController, Never>
        let openNavigation: AnyPublisher<URL, Never>
        let showToast: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        bindActions(input: input)
        
        return .init(
            visitedStations: visitedStationsPublisher(),
            showStationDetail: showStationDetailPublisher(input: input),
            openNavigation: openNavigationPublisher(input: input),
            showToast: showToastPublisher(input: input)
        )
    }
}


//MARK: - Make Publishers
private extension FrequentVisitViewModel {
    func visitedStationsPublisher() -> AnyPublisher<[VisitedGasStation], Never> {
        return visitStationsPublisher
            .map { visitedStations in
                let stationDictionary = visitedStations.reduce(into: [String: VisitedGasStation]()) { dict, station in
                    if var existingStation = dict[station.stationID] {
                        existingStation.visitCount += 1
                        dict[station.stationID] = existingStation
                    } else {
                        var newStation = station
                        dict[station.stationID] = newStation
                    }
                }
                return stationDictionary.values.sorted { $0.visitCount > $1.visitCount }
            }
            .eraseToAnyPublisher()
    }
    
    func showStationDetailPublisher(input: Input) -> AnyPublisher<UIViewController, Never> {
        return input.didSelectItem
            .map { visitStation in
                let settingStorage: SettingStorage = PlistSettingStorage()
                let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
                let stationRepository: StationRepository = StationRepositoryImpl()
                let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
                let detailViewModel = StationDetailViewModel(
                    stationID: visitStation.stationID,
                    settingUseCase: settingUseCase,
                    stationRepository: stationRepository,
                    visitedStationStorage: visitedStationStorage
                )
                return StationDetailVC(viewModel: detailViewModel)
            }
            .eraseToAnyPublisher()
    }
    
    func openNavigationPublisher(input: Input) -> AnyPublisher<URL, Never> {
        return input.didTapDirectionStation
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
    }
    
    func showToastPublisher(input: Input) -> AnyPublisher<String, Never> {
        return input.didTapFavoriteStation
            .compactMap { [weak self] visitedStation in
                guard let self,
                      let favorites: [String] = try? settingUseCase.load(type: .favorites) else {
                    return nil
                }
                
                if favorites.contains(visitedStation.stationID) {
                    return deleteFavoriteMessage(stationID: visitedStation.stationID)
                } else {
                    return addFavoriteMessage(stationID: visitedStation.stationID)
                }
            }.eraseToAnyPublisher()
    }
}


private extension FrequentVisitViewModel {
    func bindActions(input: Input) {
        input.viewDidLoad
            .sink { [weak self] _ in
                let visitedStations = self?.storage.fetchVisitedStations() ?? []
                self?.visitStationsPublisher.send(visitedStations)
            }
            .store(in: &cancellable)
    }
    
    func save(visitedStation station: VisitedGasStation) {
        Task {
            do {
                try await storage.saveVisited(station: station)
                visitStationsPublisher.send(storage.fetchVisitedStations())
            } catch {
                LogUtil.e(error.localizedDescription)
            }
        }
    }
    
    /// 즐겨찾기 추가 및 결과 메시지
    func addFavoriteMessage(stationID: String) -> String {
        if addFavoriteIfNeeded(stationID: stationID) {
            return "즐겨 찾는 주유소에 추가되었습니다."
        } else {
            return "최대 5개까지 추가 가능합니다🥹\n이전 즐겨찾기를 삭제하고 추가해주세요."
        }
    }
    /// 즐겨찾기 삭제 및 결과 메시지
    func deleteFavoriteMessage(stationID: String) -> String {
        deleteFavorite(stationID: stationID)
        return "즐겨 찾는 주유소가 삭제되었습니다."
    }
    /// 즐겨찾기 추가
    func addFavoriteIfNeeded(stationID: String) -> Bool {
        guard let favorites: [String] = try? settingUseCase.load(type: .favorites),
              favorites.count < 5 else {
            return false
        }
        var saveFavorites = Set<String>(favorites)
        saveFavorites.insert(stationID)
        updateFavoriteButtonPublisher.send(true)
        settingUseCase.save(saveFavorites.map { $0 }, type: .favorites)
        return true
    }
    /// 즐겨찾기 삭제
    func deleteFavorite(stationID: String) {
        guard var favorites: [String] = try? settingUseCase.load(type: .favorites) else {
            return
        }
        favorites.removeAll(where: { $0 == stationID })
        updateFavoriteButtonPublisher.send(false)
        settingUseCase.save(favorites, type: .favorites)
    }
}
