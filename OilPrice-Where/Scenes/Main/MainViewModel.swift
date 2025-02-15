//
//  MainViewModel.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Combine
import Foundation
import CoreLocation
import FloatingPanel


//MARK: MainViewModel
final class MainViewModel {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    private let settingUseCase: SettingUseCase
    private let stationRepository: StationRepository
    
    private(set) var stations: [GasStationSummary] = []
    private(set) var requestCoordinateSystem: CoordinateSystem? = nil
    private(set) var selectedStation: GasStationSummary? = nil
    
    var location: CLLocation?
    var zoomLevel: CGFloat?
    
    var beforeNAfter: (before: FloatingPanelState, after: FloatingPanelState) = (.hidden, .hidden)
    
    
    //MARK: - Initializer
    init(settingUseCase: SettingUseCase,
         stationRepository: StationRepository) {
        self.settingUseCase = settingUseCase
        self.stationRepository = stationRepository
    }
}


//MARK: - I/O & transform
extension MainViewModel {
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        /// 서치 바 검색
        let searchByPOI: AnyPublisher<SearchPOI, Never>
        /// 현재 위치 검색
        let searchByMap: AnyPublisher<CLLocation, Never>
        /// 설정 값 업데이트
        let updatedSettings: AnyPublisher<Void, Never>
        /// 주유소 선택
        let selectedStation: AnyPublisher<GasStationSummary, Never>
    }
    
    struct Output {
        /// 주유소 리스트 결과
        let staionsResult: AnyPublisher<[GasStationSummary], Never>
        /// 주유소 선택
        let selectedStation: AnyPublisher<GasStationSummary, Never>
        
    }
    
    func transform(input: Input) -> Output {
        return .init(
            staionsResult: staionsResultPublisher(input: input),
            selectedStation: selectedStationPublisher(input: input)
        )
    }
}


//MARK: - Make Publisher
extension MainViewModel {
    func staionsResultPublisher(input: Input) -> AnyPublisher<[GasStationSummary], Never> {
        let viewDidLoad = input.viewDidLoad
            .flatMap { _ -> AnyPublisher<CLLocation, Never> in
                LocationManager.shared.$currentLocation
                    .compactMap { $0 }
                    .first()
                    .eraseToAnyPublisher()
            }
            .map { CoordinateSystem(lat: $0.coordinate.latitude, lng: $0.coordinate.longitude) }
            .eraseToAnyPublisher()
        
        let searchByPOI = input.searchByPOI
            .compactMap { $0.coordinate }
            .eraseToAnyPublisher()
        
        let searchByMap = input.searchByMap
            .map { CoordinateSystem(lat: $0.coordinate.latitude, lng: $0.coordinate.longitude) }
            .eraseToAnyPublisher()
        
        let updatedSettings = input.updatedSettings
            .compactMap { [weak self] _ -> CoordinateSystem? in
                guard let self else { return nil }
                
                if let requestCoordinateSystem {
                    return requestCoordinateSystem
                } else if let currentLocation = LocationManager.shared.currentLocation {
                    return CoordinateSystem(lat: currentLocation.coordinate.latitude, lng: currentLocation.coordinate.longitude)
                } else {
                    return nil
                }
            }
            .eraseToAnyPublisher()
        
        let staionsResultPublisher = Publishers.Merge4(
            viewDidLoad,
            searchByPOI,
            searchByMap,
            updatedSettings
        ).eraseToAnyPublisher()
        
        return staionsResultPublisher
            .flatMap { [weak self] coordinateSystem -> AnyPublisher<[GasStationSummary], Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return Future { promise in
                    Task {
                        guard
                            let prodcd: String = try? self.settingUseCase.load(type: .fuelType),
                            let stations = try? await self.stationRepository.fetchNearbyGasStations(
                                x: coordinateSystem.katec.x,
                                y: coordinateSystem.katec.y,
                                prodcd: prodcd)
                        else {
                            return
                        }
                        self.stations = stations
                        self.requestCoordinateSystem = coordinateSystem
                        promise(.success(stations))
                    }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func selectedStationPublisher(input: Input) -> AnyPublisher<GasStationSummary, Never> {
        return input.selectedStation
            .map { [weak self] station in
                self?.selectedStation = station
                return station
            }
            .eraseToAnyPublisher()
    }
}
