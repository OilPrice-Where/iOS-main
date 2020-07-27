//
//  Station.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import SwiftyPlistManager

// App 전체에서 사용하는 싱글톤
class DefaultData {
   static let shared = DefaultData() // 싱글톤 객체 생성
   private let bag = DisposeBag()
   var reachability: Reachability? = Reachability()
   
   // 기본 설정
   private init() {
      do {
         try reachability?.startNotifier()
      } catch {
         print(error.localizedDescription)
      }
      
      setData()
   }
   var data: [GasStation]? // 반경 주유소 리스트
   var priceData: [AllPrice] = [] // 전국 평균 기름 값
   var radiusSubject = BehaviorSubject<Int>(value: 3000) // 탐색 반경
   var oilSubject = BehaviorSubject<String>(value: "") // 오일 종류
   var brandSubject = BehaviorSubject<String>(value: "") // 설정 브랜드
   var favoriteSubject = BehaviorSubject<[String]>(value: []) // 즐겨 찾기
   
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
   
   func setData() {
      SwiftyPlistManager.shared.start(plistNames: ["UserInfo"], logging: true) // Plist 불러오기
      // 탐색 반경 설정
      // 탐색 오일 설정
      guard let radius = SwiftyPlistManager.shared.fetchValue(for: "FindRadius", fromPlistWithName: "UserInfo") as? Int,
         let oilType = SwiftyPlistManager.shared.fetchValue(for: "OilType", fromPlistWithName: "UserInfo") as? String,
         let brandName = SwiftyPlistManager.shared.fetchValue(for: "BrandType", fromPlistWithName: "UserInfo") as? String,
         let favArr = SwiftyPlistManager.shared.fetchValue(for: "Favorites", fromPlistWithName: "UserInfo") as? [String] else { fatalError() }
      
      oilSubject.onNext(oilType)
      radiusSubject.onNext(radius)
      favoriteSubject.onNext(favArr)
      brandSubject.onNext(brandName)
      
      // Plist에 값 저장
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
         .subscribe(onNext: {
            print($0)
            SwiftyPlistManager.shared.save($0,
                                           forKey: "Favorites",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save Favorites !!")
                                             }}
         })
         .disposed(by: bag)
      
      // Brand Array Save
      brandSubject
         .subscribe(onNext: {
            SwiftyPlistManager.shared.save($0,
                                           forKey: "BrandType",
                                           toPlistWithName: "UserInfo") { (err) in
                                             if err != nil {
                                                print("Success Save BrandType !!")
                                             }}
         })
         .disposed(by: bag)
   }
   
   deinit {
      reachability?.stopNotifier()
      reachability = nil
   }
}
