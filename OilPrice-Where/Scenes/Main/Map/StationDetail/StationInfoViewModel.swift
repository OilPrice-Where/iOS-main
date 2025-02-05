//
//  StationInfoViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2/8/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import Combine


final class StationInfoViewModel {
    //MARK: - Properties
    private let settingUseCase: SettingUseCase
    private let stationRepository: StationRepository
    
    
    //MARK: Initializer
    init(settingUseCase: SettingUseCase,
         stationRepository: StationRepository) {
        self.settingUseCase = settingUseCase
        self.stationRepository = stationRepository
    }
    
    
    func currentFuelType() -> FuelType {
        guard let fuelCode: String = try? settingUseCase.load(type: .fuelType) else {
            return .gasoline
        }
        return FuelType(code: fuelCode)
    }
}


//MARK: - I/O & transform
extension StationInfoViewModel {
    struct Input {
        let requestStationDetail: AnyPublisher<String, Never>
        let addressButtonTapped: AnyPublisher<String?, Never>
        let phoneNumberButtonTapped: AnyPublisher<String, Never>
    }
    
    struct Output {
        let updateStationDetail: AnyPublisher<GasStationDetail, Never>
        let showToast: AnyPublisher<String, Never>
        let openURL: AnyPublisher<URL, Never>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            updateStationDetail: updateStationDetailPublisher(input: input),
            showToast: showToastPublisher(input: input),
            openURL: openUrlPublisher(input: input)
        )
    }
}


//MARK: - Make Publisher
extension StationInfoViewModel {
    func updateStationDetailPublisher(input: Input) -> AnyPublisher<GasStationDetail, Never> {
        return input.requestStationDetail
            .flatMap { [weak self] stationID -> AnyPublisher<GasStationDetail, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return Future { promise in
                    Task {
                        guard let stationDetails = try? await self.stationRepository.fetchStationDetails(id: stationID),
                              let stationDetail = stationDetails.first else {
                            return
                        }
                        promise(.success(stationDetail))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func showToastPublisher(input: Input) -> AnyPublisher<String, Never> {
        return input.addressButtonTapped
            .compactMap { address -> String? in
                guard let address, address.isNotEmpty else {
                    return nil
                }
                UIPasteboard.general.string = address
                return "주유소 주소가 복사되었습니다."
            }
            .eraseToAnyPublisher()
    }
    
    func openUrlPublisher(input: Input) -> AnyPublisher<URL, Never> {
        return input.phoneNumberButtonTapped
            .compactMap { phoneNumber in
                guard let phoneNumberURL = URL(string: phoneNumber, encodingInvalidCharacters: false) else {
                    return nil
                }
                return phoneNumberURL
            }
            .eraseToAnyPublisher()
    }
}
