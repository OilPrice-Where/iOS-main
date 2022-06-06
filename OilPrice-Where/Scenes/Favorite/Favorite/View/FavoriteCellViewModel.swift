//
//  FavoriteCellViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/02.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import UIKit
import RxSwift
import Moya
//MARK: FavoriteCellViewModel
final class FavoriteCellViewModel {
    let bag = DisposeBag()
    private var info: InformationGasStaion?
    let stationAPI = MoyaProvider<StationAPI>()
    var infoSubject = BehaviorSubject<InformationGasStaion?>(value: nil)
    var isLoadingSubject = BehaviorSubject<Bool>(value: false)
}
//MARK: Method
extension FavoriteCellViewModel {
    // Network -> Station
    func requestStationsInfo(id: String) {
        stationAPI.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
            switch $0 {
            case .success(let resp):
                guard let ret = try? resp.map(InformationOilStationResult.self),
                      let information = ret.result?.allPriceList?.first else { return }
                
                DefaultData.shared.tempFavArr.append(information)
                self.info = information
                self.infoSubject.onNext(information)
                self.isLoadingSubject.onNext(true)
            case .failure(let error):
                print(error)
            }
        }
    }
    // 가격 정보 얻기
    func displayPriceInfomation(priceList: [Price]?) -> String {
        let type = DefaultData.shared.oilSubject.value
        guard let displayInfo = priceList?.first(where: { $0.type == type }) else { return  "가격정보 없음" }
        
        let price = Preferences.priceToWon(price: displayInfo.price ?? 0)
        
        return price
    }
    // 컬러 값 얻기
    func getActivatedColor(info: String?) -> UIColor {
        return info == "Y" ? Asset.Colors.mainColor.color : .lightGray
    }
    // 즐겨찾기 삭제
    func deleteAction(id: String) {
        let oldFavArr = DefaultData.shared.favoriteSubject.value
        
        let newFavArr = oldFavArr.filter { id != $0 }
        DefaultData.shared.favoriteSubject.accept(newFavArr)
    }
    // 길 안내
    func navigationButton() -> GasStation? {
        let type = DefaultData.shared.oilSubject.value
        
        guard let info = info,
              let id = info.id,
              let brand = info.brand,
              let name = info.name,
              let kx = info.katecX,
              let ky = info.katecY,
              let price = info.price?.first(where: { $0.type == type })?.price else { return nil }
        
        return GasStation(id: id, brand: brand, name: name, price: price, distance: 0.0,
                          katecX: kx, katecY: ky)
    }
}
