//
//  DefaultData.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import Combine
import Moya

// App 전체에서 사용하는 싱글톤
class DefaultData {
    static let shared = DefaultData() // 싱글톤 객체 생성
    private var cancelbag = Set<AnyCancellable>()
    private let staionProvider = MoyaProvider<StationAPI>()
    
    // 기본 설정
    private init() {
        setData()
    }
    
    private let formatter = DateFormatter().then {
        $0.dateStyle = .full
    }
    
    var currentTime: String {
        return formatter.string(from: Date())
    }
    
    var priceData: [OilPriceResultDTO.OilPriceListDTO.OilPriceDTO] = [] // 전국 평균 기름 값
    var tempFavArr: [GasStationDetail] = []
    let stationsSubject = CurrentValueSubject<[GasStationSummary], Never>([]) // 반경 주유소 리스트
    let oilSubject = CurrentValueSubject<String, Never>("") // 오일 종류
    let brandsSubject = CurrentValueSubject<[String], Never>([]) // 설정 브랜드
    let favoriteSubject = CurrentValueSubject<[String], Never>([]) // 즐겨 찾기
    let naviSubject = CurrentValueSubject<String, Never>("kakao")
    let completedRelay = PassthroughSubject<String?, Never>()
    
    // 전군 평균 기름 값 로드 함수
    func allPriceDataLoad() {
        staionProvider.request(.oilPriceResult) {
            switch $0 {
            case .success(let resp):
                guard let decode = try? resp.map(OilPriceResultDTO.self) else { return }
                self.priceData = decode.result?.fuelPrices ?? []
            case .failure(let error):
                LogUtil.e(error.localizedDescription)
            }
        }
    }
    
    private func swiftyPlistManager<T>(save type: T, forKey key: String, to name: String = "UserInfo") {
        SwiftyPlistManager.shared.save(type, forKey: key, toPlistWithName: name) {
            if let err = $0 {
                LogUtil.e(err.localizedDescription)
                return
            }
            
            completedRelay.send(key)
        }
    }
    
    private func fetchValue<T>(defaultValue: T, for key: String, _ fromPlistWithName: String = "UserInfo") -> T {
        guard let v = SwiftyPlistManager.shared.fetchValue(for: key, fromPlistWithName: fromPlistWithName) as? T else {
            SwiftyPlistManager.shared.addNew(defaultValue, key: key,
                                             toPlistWithName: fromPlistWithName,
                                             completion: { _ in })
            
            return defaultValue
        }
        
        return v
    }
    
    func setData() {
        let defaultBrands = ["SKE", "GSC", "HDO", "SOL", "RTO", "RTX", "NHO", "ETC", "E1G", "SKG"]
        
        SwiftyPlistManager.shared.start(plistNames: ["UserInfo"], logging: true) // Plist 불러오기
        
        let localFavorites = fetchValue(defaultValue: "", for: "LocalFavorites")
        let oilType = fetchValue(defaultValue: "", for: "OilType")
        let brands = fetchValue(defaultValue: defaultBrands, for: "Brands")
        let naviType = fetchValue(defaultValue: "kakao", for: "NaviType")
        let favArr = fetchValue(defaultValue: [String](), for: "Favorites")
        let backgroundFind = fetchValue(defaultValue: false, for: "BackgroundFind")
        
        oilSubject.send(oilType)
        brandsSubject.send(brands)
        naviSubject.send(naviType == "tmap" ? "tMap" : naviType)
        favoriteSubject.send(favArr)
        
        // Oil Type Save
        oilSubject
            .sink { [weak self] type in
                guard let owner = self else { return }
                owner.swiftyPlistManager(save: type, forKey: "OilType")
            }
            .store(in: &cancelbag)
        
        // Favorites Array Save
        favoriteSubject
            .sink { [weak self] infomations in
                guard let owner = self else { return }
                owner.swiftyPlistManager(save: infomations, forKey: "Favorites")
                
                var tempArr = [String]()
                
                owner.tempFavArr = owner.tempFavArr.filter { info in
                    if !tempArr.contains(info.id) && infomations.contains(info.id) {
                        tempArr.append(info.id)
                        return true
                    }
                    return false
                }
                
                for id in infomations {
                    guard !tempArr.contains(id) else { continue }
                    owner.staionProvider.request(.stationDetail(id: id)) {
                        switch $0 {
                        case .success(let resp):
                            guard let result = try? resp.map(GasStationInfoResultDTO.self),
                                  let info = result.toDomain().first else { return }
                            
                            owner.tempFavArr.append(info)
                            
                        case .failure(let error):
                            LogUtil.e(error.localizedDescription)
                        }
                    }
                }
                
            }
            .store(in: &cancelbag)
        
        // Brand Array Save
        brandsSubject
            .sink { [weak self] type in
                guard let owner = self else { return }
                owner.swiftyPlistManager(save: type, forKey: "Brands")
            }
            .store(in: &cancelbag)
        
        // Navi Type Save
        naviSubject
            .sink { [weak self] type in
                guard let owner = self else { return }
                owner.swiftyPlistManager(save: type, forKey: "NaviType")
            }
            .store(in: &cancelbag)
    }
}
