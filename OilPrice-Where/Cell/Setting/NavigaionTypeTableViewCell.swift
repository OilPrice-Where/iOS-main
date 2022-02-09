//
//  NavigaionTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class NavigaionTypeTableViewCell: UITableViewCell {
   static let identifier = "NavigaionTypeTableViewCell"
   @IBOutlet private weak var naviTypeLabel : UILabel!
   
   // 셀 설정
   func bind(naviSubject: Observable<String>) {
      selectionStyle = .none
      
      // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
      naviSubject
         .bind(to: naviTypeLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.naviSubject
         .subscribe(onNext: {
            let type = Preferences.navigationType(name: $0)
            self.accessoryType = type == self.naviTypeLabel.text ?? "" ? .checkmark : .none
         })
         .disposed(by: rx.disposeBag)
   }
}
