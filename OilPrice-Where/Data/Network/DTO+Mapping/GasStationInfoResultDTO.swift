//
//  GasStationInfoResultDTO.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


/// 주유소 정보 결과 Response
struct GasStationInfoResultDTO: Codable {
    /// 주유소 정보 리스트를 담는 컨테이너
    let result: InformationGasStaionsDTO?
    
    private enum CodingKeys: String, CodingKey {
        case result = "RESULT"
    }
}


extension GasStationInfoResultDTO {
    /// 주유소 정보 리스트 Response
    struct InformationGasStaionsDTO: Codable {
        /// 개별 주유소 정보 리스트
        var allPriceList: [GasStationDetailDTO]?
        
        private enum CodingKeys: String, CodingKey {
            case allPriceList = "OIL"
        }
    }
}


extension GasStationInfoResultDTO.InformationGasStaionsDTO {
    /// 개별 주유소 세부 정보 Response
    struct GasStationDetailDTO: Codable {
        /// 주유소 고유 ID
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
        let name: String? // 매장 이름
        /// 주유소 주소
        let address: String?
        /// 주유소 전화번호
        let phoneNumber: String?
        /// 품질 인증 여부
        let isQualityCertified: String?
        /// 카센터 여부
        let hasRepairShop: String?
        /// 편의점 여부
        let hasConvenienceStore: String?
        /// 세차장 여부
        let hasCarWash: String?
        /// 유가 정보 리스트
        let prices: [FuelPriceDTO]?
        /// X좌표 (KATEC 좌표계)
        let katecX: Double?
        /// Y좌표 (KATEC 좌표계)
        let katecY: Double?
        
        private enum CodingKeys: String, CodingKey {
            case id = "UNI_ID"
            case brand = "POLL_DIV_CO"
            case name = "OS_NM"
            case address = "VAN_ADR"
            case phoneNumber = "TEL"
            case isQualityCertified = "KPETRO_YN"
            case hasRepairShop = "MAINT_YN"
            case hasConvenienceStore = "CVS_YN"
            case hasCarWash = "CAR_WASH_YN"
            case prices = "OIL_PRICE"
            case katecX = "GIS_X_COOR"
            case katecY = "GIS_Y_COOR"
        }
    }
}


extension GasStationInfoResultDTO.InformationGasStaionsDTO.GasStationDetailDTO {
    /// 주유소 유가 정보
    struct FuelPriceDTO: Codable {
        /// 유종 코드
        let type: String?
        /// 가격
        let price: Int?
        
        private enum CodingKeys: String, CodingKey {
            case type = "PRODCD"
            case price = "PRICE"
        }
    }
}


//MARK: - Mapping

extension GasStationInfoResultDTO {
    func toDomain() -> [GasStationDetail] {
        return result?.toDomain() ?? []
    }
}

extension GasStationInfoResultDTO.InformationGasStaionsDTO {
    func toDomain() -> [GasStationDetail] {
        return allPriceList?.map { $0.toDomain() } ?? []
    }
}

extension GasStationInfoResultDTO.InformationGasStaionsDTO.GasStationDetailDTO {
    func toDomain() -> GasStationDetail {
        return .init(
            stationID: id ?? UUID().uuidString,
            brand: .init(code: brand ?? ""),
            name: name ?? "주유소명 정보가 없습니다",
            address: address ?? "주소 정보가 제공되지 않았습니다",
            phoneNumber: phoneNumber ?? "전화번호를 확인할 수 없습니다",
            isQualityCertified: isQualityCertified?.uppercased() == "Y",
            hasRepairShop: hasRepairShop?.uppercased() == "Y",
            hasConvenienceStore: hasConvenienceStore?.uppercased() == "Y",
            hasCarWash: hasCarWash?.uppercased() == "Y",
            prices: prices?.map { $0.toDomain() } ?? [],
            coordinate: .init(x: katecX, y: katecY)
        )
    }
}


extension GasStationInfoResultDTO.InformationGasStaionsDTO.GasStationDetailDTO.FuelPriceDTO {
    func toDomain() -> FuelPrice {
        return .init(
            fuelType: .init(code: type ?? ""),
            price: price ?? .zero
        )
    }
}
