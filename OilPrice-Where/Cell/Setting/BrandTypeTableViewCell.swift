//
//  BrandTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 03/01/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class BrandTypeTableViewCell: UITableViewCell {
   static let identifier = "BrandTypeTableViewCell"
   @IBOutlet private weak var brandTypeLable : UILabel!
   
   // 셀 설정
   func bind(brandSubject: Observable<String>) {
      selectionStyle = .none
      
      // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
      brandSubject
         .bind(to: brandTypeLable.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.brandSubject
         .subscribe(onNext: {
            let name = Preferences.brand(code: $0)
            self.accessoryType = name == self.brandTypeLable.text ?? "" ? .checkmark : .none
         })
         .disposed(by: rx.disposeBag)
   }
}
