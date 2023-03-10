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
    
    var priceData: [AllPrice] = [] // 전국 평균 기름 값
    var tempFavArr: [InformationGasStaion] = []
    let stationsSubject = CurrentValueSubject<[GasStation], Never>([]) // 반경 주유소 리스트
    let oilSubject = CurrentValueSubject<String, Never>("") // 오일 종류
    let brandsSubject = CurrentValueSubject<[String], Never>([]) // 설정 브랜드
    let favoriteSubject = CurrentValueSubject<[String], Never>([]) // 즐겨 찾기
    let naviSubject = CurrentValueSubject<String, Never>("kakao")
    let localFavoritesSubject = CurrentValueSubject<String, Never>("")
    let backgroundFindSubject = CurrentValueSubject<Bool, Never>(false)
    let completedRelay = PassthroughSubject<String?, Never>()
    
    // 전군 평균 기름 값 로드 함수
    func allPriceDataLoad() {
        staionProvider.request(.allPrices(appKey: Preferences.getAppKey())) {
            switch $0 {
            case .success(let resp):
                guard let decode = try? resp.map(AllPriceResult.self) else { return }
                self.priceData = decode.result.allPriceList
            case .failure(let error):
                LogUtil.e(error.localizedDescription)
            }
        }
    }
    
    func localSave(favorites: InformationGasStaions) {
        let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere")
        
        if let encodeData = try? JSONEncoder().encode(favorites) {
            def?.set(encodeData, forKey: "FavoriteArr")
            def?.synchronize()
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
        
        localFavoritesSubject.send(localFavorites)
        oilSubject.send(oilType)
        brandsSubject.send(brands)
        naviSubject.send(naviType == "tmap" ? "tMap" : naviType)
        favoriteSubject.send(favArr)
        backgroundFindSubject.send(backgroundFind)
        
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
                
                let group = DispatchGroup()
                let queue = DispatchQueue(label: "wargi.dispatch.favorites")
                var tempArr = [String]()
                
                let dataString = owner.localFavoritesSubject.value
                if let data = dataString.data(using: .utf8),
                   let infomations = try? JSONDecoder().decode(InformationGasStaions.self, from: data),
                   let list = infomations.allPriceList {
                    owner.tempFavArr = list
                }
                
                owner.tempFavArr = owner.tempFavArr.filter { info in
                    guard let id = info.id else { return false }
                    if !tempArr.contains(id) && infomations.contains(id) {
                        tempArr.append(id)
                        return true
                    }
                    return false
                }
                
                for id in infomations {
                    guard !tempArr.contains(id) else { continue }
                    group.enter()
                    owner.staionProvider.request(.stationDetail(appKey: Preferences.getAppKey(), id: id)) {
                        switch $0 {
                        case .success(let resp):
                            guard let result = try? resp.map(InformationOilStationResult.self),
                                  let info = result.result?.allPriceList?.first else { return }
                            
                            queue.async {
                                owner.tempFavArr.append(info)
                                group.leave()
                            }
                        case .failure(let error):
                            LogUtil.e(error.localizedDescription)
                        }
                    }
                }
                
                group.notify(queue: queue) {
                    let value = InformationGasStaions(allPriceList: owner.tempFavArr)
                    if let encodeData = try? JSONEncoder().encode(value),
                       let dataString = String(data: encodeData, encoding: .utf8) {
                        owner.localFavoritesSubject.send(dataString)
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
                
                let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere")
                def?.set(type, forKey: "NaviType")
                def?.synchronize()
                owner.swiftyPlistManager(save: type, forKey: "NaviType")
            }
            .store(in: &cancelbag)
        
        // Local Favorites
        localFavoritesSubject
            .sink { [weak self] type in
                guard let owner = self else { return }
                
                var value = InformationGasStaions(allPriceList: [])
                
                guard let data = type.data(using: .utf8),
                      let infomations = try? JSONDecoder().decode(InformationGasStaions.self, from: data),
                      let list = infomations.allPriceList else {
                          if let encodeData = try? JSONEncoder().encode(value),
                             let dataString = String(data: encodeData, encoding: .utf8) {
                              owner.swiftyPlistManager(save: dataString, forKey: "LocalFavorites")
                          }
                          return
                      }
                owner.swiftyPlistManager(save: type, forKey: "LocalFavorites")
                
                value.allPriceList = owner.tempFavArr
                owner.tempFavArr = list
                owner.localSave(favorites: value)
            }
            .store(in: &cancelbag)
        
        // Background Find
        backgroundFindSubject
            .sink { [weak self] isFind in
                guard let owner = self else { return }
                owner.swiftyPlistManager(save: isFind, forKey: "BackgroundFind")
            }
            .store(in: &cancelbag)
    }
}
