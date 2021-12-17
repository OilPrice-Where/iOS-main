//
//  Station.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyPlistManager

// App 전체에서 사용하는 싱글톤
class DefaultData {
   static let shared = DefaultData() // 싱글톤 객체 생성
   private let bag = DisposeBag()
   
   // 기본 설정
   private init() {
      setData()
   }
   
   var stationsSubject = BehaviorSubject<[GasStation]>(value: []) // 반경 주유소 리스트
   var priceData: [AllPrice] = [] // 전국 평균 기름 값
   var radiusSubject = BehaviorSubject<Int>(value: 3000) // 탐색 반경
   var oilSubject = BehaviorSubject<String>(value: "") // 오일 종류
   var brandsSubject = BehaviorSubject<[String]>(value: []) // 설정 브랜드
   var favoriteSubject = BehaviorSubject<[String]>(value: []) // 즐겨 찾기
   var naviSubject = BehaviorSubject<String>(value: "kakao")
   var salesSubject = BehaviorSubject<[String: Int]>(value: [:])
   var localFavoritesSubject = BehaviorSubject<String>(value: "")
   var tempFavArr: [InformationGasStaion] = []
   
   // 전군 평균 기름 값 로드 함수
   func allPriceDataLoad() {
      ServiceList.allPriceList(appKey: Preferences.getAppKey()) { (result) in
         switch result {
         case .success(let allPriceListData):
            self.priceData = allPriceListData.result.allPriceList
         case .error(let err):
            print(err)
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
   
   private func getValue<T>(defaultValue: T, for key: String, _ fromPlistWithName: String = "UserInfo") -> T {
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
      let defaultSales = [ "SK": 0, "HDO": 0, "GSC": 0, "SOL": 0, "E1G": 0, "RTO": 0, "NHO": 0]
      
      SwiftyPlistManager.shared.start(plistNames: ["UserInfo"], logging: true) // Plist 불러오기
      
      let localFavorites = getValue(defaultValue: "", for: "LocalFavorites")
      let map = getValue(defaultValue: "AppleMap", for: "MapType")
      let radius = getValue(defaultValue: 5000, for: "FindRadius")
      let oilType = getValue(defaultValue: "", for: "OilType")
      let brands = getValue(defaultValue: defaultBrands, for: "Brands")
      let naviType = getValue(defaultValue: "kakao", for: "NaviType")
      let sales = getValue(defaultValue: defaultSales, for: "Sales")
      let favArr = getValue(defaultValue: [String](), for: "Favorites")
      
      localFavoritesSubject.onNext(localFavorites)
      oilSubject.onNext(oilType)
      radiusSubject.onNext(radius)
      brandsSubject.onNext(brands)
      naviSubject.onNext(naviType)
      salesSubject.onNext(sales)
      favoriteSubject.onNext(favArr)
            
      // Oil Type Save
      oilSubject
         .subscribe(onNext: {
            SwiftyPlistManager.shared.save($0,
                                           forKey: "OilType",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save Oil Type !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Find Radius Value Save
      radiusSubject
         .subscribe(onNext: {
            SwiftyPlistManager.shared.save($0,
                                           forKey: "FindRadius",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save Distance !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Favorites Array Save
      favoriteSubject
         .subscribe(onNext: { infomations in
            SwiftyPlistManager.shared.save(infomations,
                                           forKey: "Favorites",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save Favorites !!")
                                             }}
            
            let group = DispatchGroup()
            let queue = DispatchQueue(label: "wargi.dispatch.favorites")
            var tempArr = [String]()
            
            if let dataString = try? self.localFavoritesSubject.value(),
               let data = dataString.data(using: .utf8),
               let infomations = try? JSONDecoder().decode(InformationGasStaions.self,
                                                           from: data) {
               self.tempFavArr = infomations.allPriceList
            }
            
            self.tempFavArr = self.tempFavArr.filter { info in
               if !tempArr.contains(info.id) && infomations.contains(info.id) {
                  tempArr.append(info.id)
                  return true
               }
               return false
            }
            
            for id in infomations {
               guard !tempArr.contains(id) else { continue }
               group.enter()
               ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                                id: id) { (result) in
                  switch result {
                  case .success(let info):
                     queue.async {
                        self.tempFavArr.append(info)
                        group.leave()
                     }
                  case .error(let error):
                     print(error.localizedDescription)
                  }
               }
            }
            
            group.notify(queue: queue) {
               let value = InformationGasStaions(allPriceList: self.tempFavArr)
               if let encodeData = try? JSONEncoder().encode(value),
                  let dataString = String(data: encodeData, encoding: .utf8) {
                  self.localFavoritesSubject.onNext(dataString)
               }
            }
         })
         .disposed(by: bag)
      
      // Brand Array Save
      brandsSubject
         .subscribe(onNext: {
            SwiftyPlistManager.shared.save($0,
                                           forKey: "Brands",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save BrandType !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Navi Type Save
      naviSubject
         .subscribe(onNext: {
            let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere")
            def?.set($0, forKey: "NaviType")
            def?.synchronize()
            
            SwiftyPlistManager.shared.save($0,
                                           forKey: "NaviType",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save BrandType !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Sales Save
      salesSubject
         .subscribe(onNext: {
            SwiftyPlistManager.shared.save($0,
                                           forKey: "Sales",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save BrandType !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Local Favorites
      localFavoritesSubject
         .subscribe(onNext: {
            var value = InformationGasStaions(allPriceList: [])
            
            guard let data = $0.data(using: .utf8),
               let infomations = try? JSONDecoder().decode(InformationGasStaions.self,
                                                          from: data) else {
               if let encodeData = try? JSONEncoder().encode(value),
                  let dataString = String(data: encodeData, encoding: .utf8) {
                  SwiftyPlistManager.shared.save(dataString,
                                                 forKey: "LocalFavorites",
                                                 toPlistWithName: "UserInfo") { (err) in
                                                   if err != nil {
                                                      print("Success Save LocalFavorite !!")
                                                   }}
               }
               return
            }
            SwiftyPlistManager.shared.save($0,
                                           forKey: "LocalFavorites",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save LocalFavorite !!")
                                             }}
            
            value.allPriceList = self.tempFavArr
            self.tempFavArr = infomations.allPriceList
            self.localSave(favorites: value)
         })
         .disposed(by: bag)
   }
}
