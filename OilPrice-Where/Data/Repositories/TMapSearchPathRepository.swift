//
//  TMapSearchPathRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import TMapSDK


final class TMapSearchPathRepository: SearchPathRepository {
    private let pathData = TMapPathData()


    init() {
        setTMapAuthentication()
    }


    func requestFindAllPOIs(keyword: String, count: Int) async -> [SearchPOI] {
        await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: [])
                return
            }
            self.pathData.requestFindAllPOI(keyword, count: count) { result, error in
                if let error {
                    LogUtil.e(error.localizedDescription)
                    continuation.resume(returning: [])
                    return
                }

                let items = result ?? []
                let pois: [SearchPOI] = items.compactMap { poi in
                    guard let coordinate = poi.coordinate else {
                        return nil
                    }

                    // 1. 도로명 주소 및 상세 주소 생성
                    let roadAddress = poi.roadName ?? ""
                    let previousAddress = poi.detailAddrName ?? ""

                    // 2. 건물 번호 부분 생성
                    let buildingPart: String = {
                        // 첫 번째 건물 번호가 없으면 빈 문자열 반환
                        guard let no1 = poi.buildingNo1, no1.isNotEmpty else { return "" }

                        // 두 번째 건물 번호가 존재하고 "0"이 아니라면 하이픈으로 연결
                        if let no2 = poi.buildingNo2, no2.isNotEmpty, no2 != "0" {
                            return " \(no1)-\(no2)"
                        }

                        // 첫 번째 건물 번호만 존재할 경우
                        return " \(no1)"
                    }()

                    // 3. 상위 주소와 중간 주소 결합
                    var resultAddress = (poi.upperAddrName ?? "") + " " + (poi.middleAddrName ?? "")

                    // 4. 도로명 주소가 존재하면 사용하고, 없을 경우 상세 주소 사용
                    resultAddress += " " + (roadAddress.isEmpty ? previousAddress : roadAddress + buildingPart)

                    return SearchPOI(
                        name: poi.name ?? "",
                        address: resultAddress,
                        coordinate: CoordinateSystem(lat: coordinate.latitude, lng: coordinate.longitude),
                        insertDate: Date()
                    )
                }
                continuation.resume(returning: pois)
            }
        }
    }

    func reverseGeocoding(coordinate: CoordinateSystem) async -> String {
        return await withCheckedContinuation { [weak self] continuation in
            guard let self else {
                continuation.resume(returning: "")
                return
            }
            pathData.reverseGeocoding(coordinate.location.coordinate, addressType: "A10") { result, error in
                if let error {
                    LogUtil.e(error.localizedDescription)
                    continuation.resume(returning: "")
                    return
                }

                guard
                    let result,
                    let city = result[Constants.Parameters.city] as? String,
                    let gu = result[Constants.Parameters.gu] as? String,
                    let roadName = result[Constants.Parameters.roadName] as? String,
                    let buildingNumber = result[Constants.Parameters.buildingNumber] as? String
                else {
                    continuation.resume(returning: "")
                    return
                }
                continuation.resume(returning: "\(city) \(gu) \(roadName) \(buildingNumber)")
            }
        }
    }
}


extension TMapSearchPathRepository {
    private enum Constants {
        struct Parameters {
            static let city = "city_do"
            static let gu = "gu_gun"
            static let roadName = "roadName"
            static let buildingNumber = "buildingIndex"
        }
    }

    func setTMapAuthentication() {
        TMapApi.setSKTMapAuthenticationWithDelegate(self, apiKey: Preferences.tMapAppKey())
    }
}

extension TMapSearchPathRepository: TMapTapiDelegate {
    func SKTMapApikeySucceed() {
        LogUtil.d("TMAP API KEY 인증 성공")
    }
}
