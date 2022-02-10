//
//  FavoritesGasStationViewModel.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

final class FavoritesGasStationViewModel {
    
    var infomationsSubject = BehaviorSubject<[InformationGasStaion?]>(value: [])
    
}
