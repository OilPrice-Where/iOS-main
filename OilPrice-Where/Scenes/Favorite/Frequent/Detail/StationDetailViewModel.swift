//
//  StationDetailViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/29.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine


final class StationDetailViewModel {
    //MARK: - Properties
    private var stationDetail: GasStationDetail?
    
    private let stationID: String
    private let urlBuilder: NavigationURLBuilder
    private let settingUseCase: SettingUseCase
    private let stationRepository: StationRepository
    private let visitedStationStorage: VisitedStationStorage
    
    private let updateFavoriteButtonPublisher = CurrentValueSubject<Bool, Never>(false)
    
    //MARK: Initializer
    init(stationID: String,
         settingUseCase: SettingUseCase,
         stationRepository: StationRepository,
         visitedStationStorage: VisitedStationStorage) {
        self.stationID = stationID
        self.settingUseCase = settingUseCase
        self.stationRepository = stationRepository
        self.visitedStationStorage = visitedStationStorage
        self.urlBuilder = AppNavigationURLBuilder(settingUseCase: settingUseCase)
    }
}


//MARK: - I/O & transform
extension StationDetailViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let addressButtonTapped: AnyPublisher<String?, Never>
        let phoneNumberButtonTapped: AnyPublisher<String, Never>
        let favoriteButtonTapped: AnyPublisher<Void, Never>
        let directionButtonTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let updateStationDetail: AnyPublisher<GasStationDetail, Never>
        let updateFavoriteButton: AnyPublisher<Bool, Never>
        let showToast: AnyPublisher<String, Never>
        let openURL: AnyPublisher<URL, Never>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            updateStationDetail: updateStationDetailPublisher(input: input),
            updateFavoriteButton: updateFavoriteButtonPublisher.eraseToAnyPublisher(),
            showToast: showToastPublisher(input: input),
            openURL: openUrlPublisher(input: input)
        )
    }
}


//MARK: - Make Publisher
extension StationDetailViewModel {
    func updateStationDetailPublisher(input: Input) -> AnyPublisher<GasStationDetail, Never> {
        return input.viewDidLoad
            .flatMap { [weak self] _ -> AnyPublisher<GasStationDetail, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                let favorites: [String]? = try? settingUseCase.load(type: .favorites)
                updateFavoriteButtonPublisher.send(favorites?.contains(stationID) ?? false)
                
                return fetchStationDetail()
            }
            .eraseToAnyPublisher()
    }
    
    func showToastPublisher(input: Input) -> AnyPublisher<String, Never> {
        let addressToastPublisher = input.addressButtonTapped
            .compactMap { address -> String? in
                guard let address, address.isNotEmpty else {
                    return nil
                }
                UIPasteboard.general.string = address
                return "주유소 주소가 복사되었습니다."
            }
        
        let favoriteToastPublisher = input.favoriteButtonTapped
            .compactMap { [weak self] _ -> String? in
                guard let self,
                      let favorites: [String] = try? settingUseCase.load(type: .favorites) else {
                    return nil
                }
                
                if favorites.contains(stationID) {
                    return deleteFavoriteMessage(favorites: favorites)
                } else {
                    return addFavoriteMessage(favorites: favorites)
                }
            }
        
        return Publishers.Merge(
            addressToastPublisher.eraseToAnyPublisher(),
            favoriteToastPublisher.eraseToAnyPublisher()
        ).eraseToAnyPublisher()
    }
    
    func openUrlPublisher(input: Input) -> AnyPublisher<URL, Never> {
        let openPhoneNumberPublisher = input.phoneNumberButtonTapped
            .compactMap { phoneNumber -> URL? in
                guard let phoneNumberURL = URL(string: phoneNumber, encodingInvalidCharacters: false) else {
                    return nil
                }
                return phoneNumberURL
            }
        
        let openNavigation = input.directionButtonTapped
            .compactMap { [weak self] _ -> URL? in
                guard let self,
                      let stationDetail else {
                    return nil
                }
                // 방문 주유소 저장
                saveStation()
                
                let destinationURL = urlBuilder.destinationURL(
                    name: stationDetail.name,
                    coordinate: stationDetail.coordinate
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
}


//MARK: Methods
private extension StationDetailViewModel {
    func fetchStationDetail() -> AnyPublisher<GasStationDetail, Never> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self,
                          let stationDetails = try? await stationRepository.fetchStationDetails(id: stationID),
                          let stationDetail = stationDetails.first else {
                        return
                    }
                    self.stationDetail = stationDetail
                    Task { @MainActor in
                        promise(.success(stationDetail))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    /// 길 찾기 전 방문기록 저장
    func saveStation() {
        guard let stationDetail,
              let fuelCode: String = try? settingUseCase.load(type: .fuelType) else {
            return
        }
        
        Task {
            let fuelPrice = stationDetail.prices.first(where: { $0.fuelType.code == fuelCode })
            
            try await visitedStationStorage.saveVisited(station: .init(
                stationID: stationID,
                brand: stationDetail.brand,
                name: stationDetail.name,
                fuelType: fuelPrice?.fuelType ?? .gasoline,
                recordedPrice: Double(fuelPrice?.price ?? .zero),
                coordinate: stationDetail.coordinate,
                visitDate: .init()
            ))
        }
    }
    /// 즐겨찾기 추가 및 결과 메시지
    func addFavoriteMessage(favorites: [String]) -> String {
        if addFavoriteIfNeeded(favorites: favorites) {
            return "즐겨 찾는 주유소에 추가되었습니다."
        } else {
            return "최대 5개까지 추가 가능합니다🥹\n이전 즐겨찾기를 삭제하고 추가해주세요."
        }
    }
    /// 즐겨찾기 삭제 및 결과 메시지
    func deleteFavoriteMessage(favorites: [String]) -> String {
        deleteFavorite(favorites: favorites)
        return "즐겨 찾는 주유소가 삭제되었습니다."
    }
    /// 즐겨찾기 추가
    func addFavoriteIfNeeded(favorites: [String]) -> Bool {
        guard favorites.count < 5 else {
            return false
        }
        var saveFavorites = Set<String>(favorites)
        saveFavorites.insert(stationID)
        updateFavoriteButtonPublisher.send(true)
        settingUseCase.save(saveFavorites.map { $0 }, type: .favorites)
        return true
    }
    /// 즐겨찾기 삭제
    func deleteFavorite(favorites: [String]) {
        var saveFavorites = favorites
        saveFavorites.removeAll(where: { $0 == stationID })
        updateFavoriteButtonPublisher.send(false)
        settingUseCase.save(saveFavorites, type: .favorites)
    }
}
