//
//  FavoriteStationsViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/02.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine


//MARK: FavoriteCellViewModel
final class FavoriteStationsViewModel {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    /// 사용자가 설정한 찾는 유종 정보
    private(set) var fuelType: FuelType
    
    private let settingUseCase: SettingUseCase
    private let urlBuilder: NavigationURLBuilder
    private let stationRepository: StationRepository
    private let visitedStationStorage: VisitedStationStorage
    
    private let favoriteStationsPublisher: CurrentValueSubject<[GasStationDetail], Never> = .init([])
    
    
    //MARK: - Initializer
    init(settingUseCase: SettingUseCase,
         stationRepository: StationRepository,
         visitedStationStorage: VisitedStationStorage) {
        self.settingUseCase = settingUseCase
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
        self.stationRepository = stationRepository
        self.visitedStationStorage = visitedStationStorage
        let fuelCode: String? = try? settingUseCase.load(type: .fuelType)
        self.fuelType = FuelType(code: fuelCode ?? "")
    }
}


//MARK: - I/O & transform
extension FavoriteStationsViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 주유소 주소 복사
        let didTapAddressStation: AnyPublisher<GasStationDetail, Never>
        /// 주유소에 전화걸기
        let didTapPhoneNumberStation: AnyPublisher<GasStationDetail, Never>
        /// 길찾기 및 방문 주유소 저장
        let didTapDirectionStation: AnyPublisher<GasStationDetail, Never>
        /// 즐겨찾기 삭제
        let didTapDeleteFavoriteStation: AnyPublisher<GasStationDetail, Never>
    }
    
    struct Output {
        let favoriteStations: AnyPublisher<[GasStationDetail], Never>
        let openURL: AnyPublisher<URL, Never>
        let showToast: AnyPublisher<String, Never>
    }
    
    func transform(input: Input) -> Output {
        bindActions(input: input)
        
        return .init(
            favoriteStations: favoriteStations(),
            openURL: openUrlPublisher(input: input),
            showToast: showToastPublisher(input: input)
        )
    }
}


//MARK: - Make Publishers
private extension FavoriteStationsViewModel {
    func favoriteStations() -> AnyPublisher<[GasStationDetail], Never> {
        return favoriteStationsPublisher
            .map { favoriteStations in
                favoriteStations.sorted { $0.name < $1.name }
            }
            .eraseToAnyPublisher()
    }
    
    func openUrlPublisher(input: Input) -> AnyPublisher<URL, Never> {
        let openPhoneNumberPublisher = input.didTapPhoneNumberStation
            .compactMap { station -> URL? in
                guard let phoneNumberURL = URL(string: "tel:" + station.phoneNumber, encodingInvalidCharacters: false) else {
                    return nil
                }
                return phoneNumberURL
            }
        
        let openNavigation = input.didTapDirectionStation
            .compactMap { [weak self] station -> URL? in
                guard let self else {
                    return nil
                }
                // 방문 주유소 저장
                saveStation(station)
                
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
        
        return Publishers.Merge(
            openPhoneNumberPublisher.eraseToAnyPublisher(),
            openNavigation.eraseToAnyPublisher()
        ).eraseToAnyPublisher()
    }
    
    func showToastPublisher(input: Input) -> AnyPublisher<String, Never> {
        let addressToastPublisher = input.didTapAddressStation
            .filter { $0.address.isNotEmpty }
            .compactMap { station -> String? in
                UIPasteboard.general.string = station.address
                return "주유소 주소가 복사되었습니다."
            }
        
        let favoriteToastPublisher = input.didTapDeleteFavoriteStation
            .compactMap { [weak self] station -> String? in
                guard let self else {
                    return nil
                }
                return deleteFavorite(stationID: station.id)
            }
        
        return Publishers.Merge(
            addressToastPublisher.eraseToAnyPublisher(),
            favoriteToastPublisher.eraseToAnyPublisher()
        ).eraseToAnyPublisher()
    }
}


//MARK: Method
private extension FavoriteStationsViewModel {
    func bindActions(input: Input) {
        let fuelTypeNotificationPublisher = NotificationCenter.default
            .publisher(for: SettingType.fuelType.notificationName)
            .compactMap { $0.object as? String }
            .compactMap { [weak self] fuelCode in
                self?.fuelType = .init(code: fuelCode)
            }
        
        let settingPublisher = Publishers.Merge(
            input.viewDidLoad.eraseToAnyPublisher(),
            fuelTypeNotificationPublisher.eraseToAnyPublisher()
        )
            .compactMap { [weak self] _ -> [String]? in
                guard let favorites: [String]? = try? self?.settingUseCase.load(type: .favorites) else {
                    return nil
                }
                return favorites
            }
        
        let favoritesNotificationPublisher = NotificationCenter.default
            .publisher(for: SettingType.favorites.notificationName)
            .compactMap { $0.object as? [String] }
        
        
        Publishers.Merge(
            settingPublisher.eraseToAnyPublisher(),
            favoritesNotificationPublisher.eraseToAnyPublisher()
        )
        .sink { [weak self] favorites in
            guard let self else {
                return
            }
            
            Task {
                let favoriteStations = await withTaskGroup(of: GasStationDetail?.self) { group in
                    for stationID in favorites {
                        group.addTask {
                            let details = try? await self.stationRepository.fetchStationDetails(id: stationID)
                            return details?.first
                        }
                    }
                    
                    var details: [GasStationDetail] = []
                    for await detail in group {
                        if let detail = detail {
                            details.append(detail)
                        }
                    }
                    return details
                }
                self.favoriteStationsPublisher.send(favoriteStations)
            }
        }
        .store(in: &cancellable)
    }
    
    /// 길 찾기 전 방문기록 저장
    func saveStation(_ station: GasStationDetail) {
        guard let fuelCode: String = try? settingUseCase.load(type: .fuelType) else {
            return
        }
        
        Task {
            let fuelPrice = station.prices.first(where: { $0.fuelType.code == fuelCode })
            
            try await visitedStationStorage.saveVisited(station: .init(
                id: station.id,
                brand: station.brand,
                name: station.name,
                fuelType: fuelPrice?.fuelType ?? .gasoline,
                recordedPrice: Double(fuelPrice?.price ?? .zero),
                coordinate: station.coordinate,
                visitDate: .init()
            ))
        }
    }
    
    /// 즐겨찾기 삭제
    func deleteFavorite(stationID: String) -> String {
        guard var favorites: [String] = try? settingUseCase.load(type: .favorites) else {
            return "즐겨 찾는 주유소를 삭제하는데 실패했습니다."
        }
        favorites.removeAll(where: { $0 == stationID })
        settingUseCase.save(favorites, type: .favorites)
        return "즐겨 찾는 주유소가 삭제되었습니다."
    }
}
