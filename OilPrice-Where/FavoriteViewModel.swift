//
//  FavoriteViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation
import RxSwift

final class FavoriteViewModel {
   let workingQueue = DispatchQueue(label: "station.info.concurrent", attributes: .concurrent)
   let group = DispatchGroup()
   let bag = DisposeBag()
   private var favoriteArr = [InformationGasStaion]()
   var favoriteArrSubject = BehaviorSubject<[InformationGasStaion]>(value: [])
   
   func getStationsInfo(id: String) {
      group.enter()
      workingQueue.async {
               ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                          id: id) { (result) in
                                             switch result {
                                             case .success(let infomation):
                                                self.favoriteArr.append(infomation)
                                                self.group.leave()
                                             case .error(_):
                                                break
                                             }
         }
      }
   }
   
   func defaultSetting() {
      DefaultData.shared.favoriteSubject
         .subscribe(onNext: { favArr in

            self.favoriteArr = []
            favArr.forEach { self.getStationsInfo(id: $0) }
            
            self.group.notify(queue: self.workingQueue) {
               print("END")
               self.favoriteArrSubject.onNext(self.favoriteArr)
            }
         })
         .disposed(by: bag)
      
   }
   
   init() {
      defaultSetting()
   }
}
