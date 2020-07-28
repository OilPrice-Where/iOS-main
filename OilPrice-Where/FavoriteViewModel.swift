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
   
   func getStationsInfo(id: String, completion: @escaping (InformationGasStaion) -> ()) {
      ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                       id: id) { (result) in
                                          switch result {
                                          case .success(let infomation):
                                             completion(infomation)
                                          case .error(_):
                                             break
                                          }
      }
   }
}
