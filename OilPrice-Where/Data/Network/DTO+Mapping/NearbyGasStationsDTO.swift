//
//  NearbyGasStationsDTO.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import NMapsMap
import CoreLocation
import KakaoSDKNavi


/// 주변 주유소 정보 Response
struct NearbyGasStationsDTO: Decodable {
    let result: GasStationListDTO?
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}


extension NearbyGasStationsDTO {
    /// 주유소 리스트 정보 Response
    struct GasStationListDTO: Decodable {
        let gasStations: [GasStationSummaryDTO]?
        
        private enum CodingKeys: String, CodingKey {
            case gasStations = "OIL"
        }
    }
}


extension NearbyGasStationsDTO.GasStationListDTO {
    /// 주유소 정보 Response
    struct GasStationSummaryDTO: Decodable, Hashable {
        /// 주유소 코드
        let id: String?
        /// 브랜드 코드
        /// - NOTE
        ///   - SKE: SK에너지
        ///   - GSC: GS칼텍스
        ///   - HDO: 현대오일뱅크
        ///   - SOL: S-OIL
        ///   - RTO: 자영알뜰
        ///   - RTX: 고속도로알뜰
        ///   - NHO: 농협알뜰
        ///   - ETC: 자가상표
        ///   - E1G: E1
        ///   - SKG: SK가스
        let brand: String?
        /// 매장 이름
        let name: String?
        /// 가격
        var price: Int?
        /// 기준 위치로부터의 거리 (단위 : m)
        var distance: Double?
        /// X좌표(KATEC)
        let katecX: Double?
        /// Y좌표(KATEC)
        let katecY: Double?
        
        private enum CodingKeys: String, CodingKey {
            case id = "UNI_ID"
            case brand = "POLL_DIV_CD"
            case name = "OS_NM"
            case price = "PRICE"
            case distance = "DISTANCE"
            case katecX = "GIS_X_COOR"
            case katecY = "GIS_Y_COOR"
        }
    }
}


extension NearbyGasStationsDTO {
    func toDomain() -> [GasStationSummary] {
        return result?.toDomain() ?? []
    }
}


extension NearbyGasStationsDTO.GasStationListDTO {
    func toDomain() -> [GasStationSummary] {
        return gasStations?.map { $0.toDomain() } ?? []
    }
}


extension NearbyGasStationsDTO.GasStationListDTO.GasStationSummaryDTO {
    func toDomain() -> GasStationSummary {
        .init(
            id: id ?? UUID().uuidString,
            brand: StationBrand(code: brand ?? ""),
            name: name ?? "",
            price: price ?? .zero,
            distance: distance ?? .zero,
            coordinate: CoordinateSystem(
                x: katecX,
                y: katecY
            )
        )
    }
}
