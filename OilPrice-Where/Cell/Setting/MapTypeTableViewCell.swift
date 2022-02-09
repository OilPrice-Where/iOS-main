//
//  MapTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/21.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class MapTypeTableViewCell: UITableViewCell {
   static let identifier = "MapTypeTableViewCell"
   @IBOutlet private weak var mapTypeLabel: UILabel!
   
   // 셀 설정
   func bind(mapSubject: Observable<String>) {
      selectionStyle = .none
      
      mapSubject
         .bind(to: mapTypeLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.mapsSubject
         .subscribe(onNext: {
            let type = Preferences.mapsType(code: $0)
            self.accessoryType = type == self.mapTypeLabel.text ?? "" ? .checkmark : .none
         })
         .disposed(by: rx.disposeBag)
   }
}
