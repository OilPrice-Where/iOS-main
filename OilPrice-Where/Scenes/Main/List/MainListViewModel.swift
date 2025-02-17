//
//  MainListViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine

//MARK: MainListViewModel
final class MainListViewModel {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    private var stations: [GasStationSummary] = []
    
    private let visitedStationStorage: VisitedStationStorage
    private(set) var settingUseCase: SettingUseCase
    private let urlBuilder: NavigationURLBuilder
    
    
    //MARK: Initializer
    init(stations: [GasStationSummary],
         settingUseCase: SettingUseCase,
         visitedStationStorage: VisitedStationStorage) {
        self.stations = stations
        self.settingUseCase = settingUseCase
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
        self.visitedStationStorage = visitedStationStorage
    }
}

//MARK: - I/O & Transform
extension MainListViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let didTapSortButton: AnyPublisher<Bool, Never>
        let didTapFavoriteStation: AnyPublisher<String, Never>
        let didTapDirectionStation: AnyPublisher<GasStationSummary, Never>
    }
    
    struct Output {
        let updateStations: AnyPublisher<[GasStationSummary], Never>
        let updateAddress: AnyPublisher<String, Never>
        let showToast: AnyPublisher<String, Never>
        let openNavigation: AnyPublisher<URL, Never>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            updateStations: updateStationsPublisher(input: input),
            updateAddress: updateAddressPublisher(input: input),
            showToast: showToastPublisher(input: input),
            openNavigation: openNavigationPublisher(input: input)
        )
    }
}

private extension MainListViewModel {
    func updateStationsPublisher(input: Input) -> AnyPublisher<[GasStationSummary], Never> {
        return Publishers.Merge(
            input.viewDidLoad.map { true }.eraseToAnyPublisher(),
            input.didTapSortButton
        ).map { [weak self] isPriceSort in
            return self?.updateStations(isPriceSort: isPriceSort) ?? []
        }.eraseToAnyPublisher()
    }
    
    func updateAddressPublisher(input: Input) -> AnyPublisher<String, Never> {
        input.viewDidLoad
            .flatMap {
                Future<String, Never> { promise in
                    Task {
                        let fullAddress = await LocationManager.shared.addressUpdate()
                        promise(.success(fullAddress))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func showToastPublisher(input: Input) -> AnyPublisher<String, Never> {
        return input.didTapFavoriteStation
            .compactMap { [weak self] stationID in
                guard let self,
                      let favorites: [String] = try? settingUseCase.load(type: .favorites) else {
                    return nil
                }
                
                if favorites.contains(stationID) {
                    return deleteFavoriteMessage(stationID: stationID)
                } else {
                    return addFavoriteMessage(stationID: stationID)
                }
            }.eraseToAnyPublisher()
    }
    
    func openNavigationPublisher(input: Input) -> AnyPublisher<URL, Never> {
        return input.didTapDirectionStation
            .compactMap { [weak self] station in
                guard let self else {
                    return nil
                }
                
                save(station: station)
                
                let destinationURL = urlBuilder.destinationURL(
                    name: station.name,
                    coordinate: station.coordinate
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
}

//MARK: - Methods
private extension MainListViewModel {
    func updateStations(isPriceSort: Bool) -> [GasStationSummary] {
        return isPriceSort ? stations.sorted(by: { $0.price < $1.price }) : stations.sorted(by: { $0.distance < $1.distance })
    }
    
    func save(station: GasStationSummary) {
        Task {
            do {
                let fuelCode: String = try settingUseCase.load(type: .fuelType)
                let visitStation: VisitedGasStation = .init(
                    stationID: station.stationID,
                    brand: station.brand,
                    name: station.name,
                    fuelType: FuelType(code: fuelCode),
                    recordedPrice: Double(station.price),
                    coordinate: station.coordinate,
                    visitDate: Date()
                )
                try await visitedStationStorage.saveVisited(station: visitStation)
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
        settingUseCase.save(saveFavorites.map { $0 }, type: .favorites)
        return true
    }
    /// 즐겨찾기 삭제
    func deleteFavorite(stationID: String) {
        guard var favorites: [String] = try? settingUseCase.load(type: .favorites) else {
            return
        }
        favorites.removeAll(where: { $0 == stationID })
        settingUseCase.save(favorites, type: .favorites)
    }
}
