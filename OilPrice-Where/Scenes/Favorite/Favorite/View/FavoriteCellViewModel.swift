//
//  FavoriteCellViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/02.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Combine
import UIKit
import Moya
//MARK: FavoriteCellViewModel
final class FavoriteCellViewModel {
    var cancellable = Set<AnyCancellable>()
    private var info: GasStationDetail?
    let stationAPI = MoyaProvider<StationAPI>()
    var infoSubject = CurrentValueSubject<GasStationDetail?, Never>(nil)
    var isLoadingSubject = CurrentValueSubject<Bool, Never>(false)
}
//MARK: Method
extension FavoriteCellViewModel {
    // Network -> StationEntity
    func requestStationsInfo(id: String) {
        stationAPI.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
            switch $0 {
            case .success(let resp):
                guard let result = try? resp.map(GasStationInfoResultDTO.self),
                      let information = result.toDomain().first else { return }
                
                DefaultData.shared.tempFavArr.append(information)
                self.info = information
                self.infoSubject.send(information)
                self.isLoadingSubject.send(true)
            case .failure(let error):
                LogUtil.e(error)
            }
        }
    }
    // 가격 정보 얻기
    func displayPriceInfomation(priceList: [FuelPrice]?) -> String {
        let type = DefaultData.shared.oilSubject.value
        guard let displayInfo = priceList?.first(where: { $0.fuelType.code == type }) else { return  "가격정보 없음" }
        
        return displayInfo.price.decimalNumber
    }
    // 컬러 값 얻기
    func getActivatedColor(info: String?) -> UIColor {
        return info == "Y" ? Asset.Colors.mainColor.color : .lightGray
    }
    // 즐겨찾기 삭제
    func deleteAction(id: String) {
        let oldFavArr = DefaultData.shared.favoriteSubject.value
        
        let newFavArr = oldFavArr.filter { id != $0 }
        DefaultData.shared.favoriteSubject.send(newFavArr)
    }
    // 길 안내
    func navigationButton() -> GasStationSummary? {
        let type = DefaultData.shared.oilSubject.value
        
        guard let info,
              let price = info.prices.first(where: { $0.fuelType.code == type })?.price else {
            return nil
        }
        
        return GasStationSummary(
            id: info.id,
            brand: info.brand,
            name: info.name,
            price: price,
            distance: .zero,
            coordinate: info.coordinate
        )
    }
}
