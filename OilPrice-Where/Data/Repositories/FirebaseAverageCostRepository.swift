//
//  FirebaseAverageCostRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


final class FirebaseAverageCostRepository: AverageCostRepository {
    let reference: DatabaseReference
    let stationRepository: StationRepository
    
    init(stationRepository: StationRepository) {
        self.stationRepository = stationRepository
        self.reference = Database.database().reference()
    }
    
    func fetchAverageCost(for productName: String) async throws -> NSDictionary {
        let systemDataRef = reference.child(Constants.FirebasePath.SystemData.root)
        let averageCostListRef = systemDataRef.child(Constants.FirebasePath.SystemData.AverageCostList.root)
        let productPath = averageCostListRef.child(productName)
        
        return try await fetchSnapShotValue(reference: productPath)
    }
    
    func checkAndUpdateAverageCosts() {
        let systemDataRef = reference.child(Constants.FirebasePath.SystemData.root)
        let averageCostListRef = systemDataRef.child(Constants.FirebasePath.SystemData.AverageCostList.root)
        let updateTimePath = averageCostListRef.child(Constants.FirebasePath.SystemData.AverageCostList.UpdateTime.root)
        
        Task {
            let lastUpdateTime: String? = try? await fetchSnapShotValue(reference: updateTimePath)
            
            // 현재 날짜와 마지막 업데이트 시간 비교 후 업데이트가 필요한지 여부
            let currentDateString = currentDateString()
            let needsUpdate = currentDateString != lastUpdateTime
            
            guard needsUpdate else {
                return
            }
            
            do {
                let prices = try await stationRepository.fetchOilPriceResult()
                handlePrices(prices, averageCostListRef: averageCostListRef)
            } catch {
                LogUtil.e("Request failed: \(error.localizedDescription)")
            }
        }
    }
}


// MARK: - Private Helper Methods
private extension FirebaseAverageCostRepository {
    func fetchSnapShotValue<T>(reference path: DatabaseReference) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            path.observeSingleEvent(of: DataEventType.value, with: { snapshot in
                guard let averageCost = snapshot.value as? T else {
                    continuation.resume(throwing: FirebaseError.emptyData)
                    return
                }
                continuation.resume(returning: averageCost)
            }, withCancel: { error in
                continuation.resume(throwing: error)
            })
        }
    }
    
    /// 유가 정보 리스트를 Firebase에 업데이트
    func handlePrices(_ prices: [OilPrice], averageCostListRef path: DatabaseReference) {
        for price in prices {
            processPrice(price, averageCostListRef: path)
        }
        
        // 마지막 업데이트 시간을 첫 데이터의 tradeDate로 갱신
        if let firstTradeDate = prices.first?.tradeDate {
            path.updateChildValues(["updateTime": firstTradeDate])
        }
    }
    
    /// 유가 정보를 처리하고 Firebase를 업데이트
    func processPrice(_ price: OilPrice, averageCostListRef path: DatabaseReference) {
        let oilName = price.oilName
        let priceInteger = Int(price.oilPrice.components(separatedBy: ".").first ?? "0") ?? .zero
        let convertedPrice = priceInteger.decimalNumber
        let priceDifferenceFlag = !price.diff.hasPrefix("-")
        let updateCostData: [String: Any] = [
            "difference": priceDifferenceFlag,
            "price": convertedPrice
        ]
        
        // update
        path
            .child(oilName)
            .updateChildValues(updateCostData)
    }
    
    /// 현재 날짜를 "yyyyMMdd" 형식의 문자열로 반환
    func currentDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
}


extension FirebaseAverageCostRepository {
    private enum Constants {
        enum FirebasePath {
            enum SystemData {
                static let root = "systemData"
                
                enum AverageCostList {
                    static let root = "averageCostList"
                    
                    enum UpdateTime {
                        static let root = "updateTime"
                    }
                }
            }
        }
    }
}
