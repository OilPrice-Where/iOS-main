//
//  FirebaseAverageCostRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/18/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import Moya
import Firebase
import FirebaseDatabase



final class FirebaseAverageCostRepository: AverageCostRepository {
    let reference: DatabaseReference
    let provider = MoyaProvider<StationAPI>()
    
    init(reference: DatabaseReference) {
        self.reference = Database.database().reference()
    }
    
    func fetchAverageCost(for productName: String) async throws -> NSDictionary {
        let systemDataRef = reference.child(Constants.FirebasePath.SystemData.root)
        let averageCostListRef = systemDataRef.child(Constants.FirebasePath.SystemData.AverageCostList.root)
        let productPath = averageCostListRef.child(productName)
        
        return try await withCheckedThrowingContinuation { continuation in
            productPath.observeSingleEvent(of: DataEventType.value, with: { snapshot in
                guard let averageCost = snapshot.value as? NSDictionary else {
                    continuation.resume(throwing: FirebaseRepositoryError.emptyData)
                    return
                }
                continuation.resume(returning: averageCost)
            })
        }
    }
    
    func checkAndUpdateAverageCosts() {
        let currentDateString = currentDateString()
        
        let systemDataRef = reference.child(Constants.FirebasePath.SystemData.root)
        let averageCostListRef = systemDataRef.child(Constants.FirebasePath.SystemData.AverageCostList.root)
        let updateTimePath = averageCostListRef.child(Constants.FirebasePath.SystemData.AverageCostList.UpdateTime.root)
        
        updateTimePath.observeSingleEvent(of: DataEventType.value, with: { [weak self] snapshot in
            guard let self else { return }
            
            let lastUpdateTime = snapshot.value as? String ?? ""
            // 현재 날짜와 마지막 업데이트 시간 비교 후 업데이트가 필요한지 여부
            let needsUpdate = currentDateString != lastUpdateTime
            
            guard needsUpdate else {
                return
            }
            
            provider.request(.oilPriceResult(appKey: Preferences.getAppKey())) { result in
                switch result {
                case .success(let response):
                    
                case .failure(let error):
                    LogUtil.e("Moya request failed: \(error.localizedDescription)")
                }
            }
        })
    }
}


extension FirebaseAverageCostRepository {
    enum FirebaseRepositoryError: Error, LocalizedError {
        case emptyData
        
        var errorDescription: String? {
            switch self {
            case .emptyData:
                return "데이터가 없습니다."
            }
        }
    }
    
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
    
    // MARK: - Private Helper Methods
    
    /// 현재 날짜를 "yyyyMMdd" 형식의 문자열로 반환
    private func currentDateString() -> String {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter.string(from: date)
    }
    
    /// Moya 응답을 처리하고 Firebase를 업데이트
    private func handleAllPricesResponse(_ response: Response, databaseRef: DatabaseReference) {
        do {
            let decodedResult = try response.map(AllPriceResult.self)
            guard let prices = decodedResult.result?.allPriceList else {
                LogUtil.e("No prices found in response")
                return
            }
            processPrices(prices, databaseRef: databaseRef)
        } catch {
            LogUtil.e("Failed to decode AllPriceResult: \(error.localizedDescription)")
        }
    }
    
    /// 유가 정보를 처리하고 Firebase를 업데이트
    private func processPrices(_ prices: [AllPrice], databaseRef: DatabaseReference) {
        for data in prices {
            guard let productName = mapOilCodeToProductName(oilCode: data.oilCode ?? "") else {
                continue
            }
            
            let priceInteger = Int(data.price?.components(separatedBy: ".").first ?? "0") ?? 0
            let convertedPrice = Preferences.priceToWon(price: priceInteger)
            
            let priceDifferenceFlag = !data.diff?.hasPrefix("-") ?? true
            
            let updateCostData: [String: Any] = [
                "difference": priceDifferenceFlag,
                "price": convertedPrice
            ]
            
            databaseRef.child(FirebasePath.SystemData.root)
                       .child(FirebasePath.SystemData.AverageCostList.root)
                       .child(productName)
                       .updateChildValues(updateCostData)
        }
        
        // 마지막 업데이트 시간을 첫 데이터의 tradeDate로 갱신
        if let firstTradeDate = prices.first?.tradeDate {
            databaseRef.child(FirebasePath.SystemData.root)
                       .child(FirebasePath.SystemData.AverageCostList.root)
                       .updateChildValues(["updateTime": firstTradeDate])
        }
    }
}
