//
//  FavoritesGasStationViewModel.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
//MARK: FavoritesGasStationViewModel
final class FavoritesGasStationViewModel {
    var infomationsSubject = BehaviorSubject<[InformationGasStaion?]>(value: [])
}
