//
//  StationDetailViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/29.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Moya
import UIKit
import Combine

//MARK: StationDetailViewModel
final class StationDetailViewModel {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let input = Input()
    let output = Output()
    private var info: InformationGasStaion? { didSet { output.infoSubject.send(info) } }
    let stationAPI = MoyaProvider<StationAPI>()
    
    //MARK: Initializer
    init() {
        bind()
    }
    
    //MARK: Binding..
    func bind() {
        input.requestStationsInfo
            .sink { [weak self] id in
                guard let owner = self else { return }
                owner.requestStationsInfo(id: id)
            }
            .store(in: &cancelBag)
    }
}

//MARK: - I/O & Error
extension StationDetailViewModel {
    enum ErrorResult: Error {
        case someError
    }
    
    struct Input {
        let requestStationsInfo = PassthroughSubject<String?, Never>()
    }
    
    struct Output {
        var infoSubject = CurrentValueSubject<InformationGasStaion?, Never>(nil)
    }
}

//MARK: - Method
extension StationDetailViewModel {
    // Network -> Station
    func requestStationsInfo(id: String?) {
        guard let id = id else {
            return
        }

        stationAPI.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
            switch $0 {
            case .success(let resp):
                guard let ret = try? resp.map(InformationOilStationResult.self),
                      let information = ret.result?.allPriceList?.first else { return }
                
                DefaultData.shared.tempFavArr.append(information)
                self.info = information
            case .failure(let error):
                LogUtil.e(error)
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
    // 컬러 값 얻기
    func fetchActivatedColor(info: String?) -> UIColor {
        return info == "Y" ? Asset.Colors.mainColor.color : .lightGray
    }
    func string(_ info: InformationGasStaion, to code: String) -> String {
        let price = Preferences.priceToWon(price: info.price?.first(where: { $0.type == code })?.price ?? 0)
        return price == "0" ? "가격 정보 없음" : price
    }
    
    func fetchStation() -> GasStation? {
        guard let station = info else { return nil }
        
        return GasStation(id: station.id ?? "", name: station.name ?? "", brand: station.brand ?? "",
                          x: station.katecX ?? .zero, y: station.katecY ?? .zero)
    }
}
