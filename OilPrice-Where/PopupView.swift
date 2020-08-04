//
//  PopupView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 01/02/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class PopupView: UIView {
   @IBOutlet private weak var minPriceLabel : UILabel!
   @IBOutlet private weak var avePriceLabel : UILabel!
   @IBOutlet private weak var radiusLabel : UILabel!
   @IBOutlet private weak var stationCountLabel : UILabel!
   
   func configure() {
      DefaultData.shared.stationsSubject
         .map { $0.isEmpty ? 0 : $0[0].price }
         .map { Preferences.priceToWon(price: $0) }
         .bind(to: minPriceLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.stationsSubject
         .map { $0.map { $0.price } }
         .map { $0.reduce(0, +) / ($0.isEmpty ? 1 : $0.count) }
         .map { Preferences.priceToWon(price: $0) }
         .bind(to: avePriceLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.radiusSubject
         .map { "\($0 / 1000)KM" }
         .bind(to: radiusLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.stationsSubject
         .map { "\($0.count)개" }
         .bind(to: stationCountLabel.rx.text)
         .disposed(by: rx.disposeBag)
   }
}
