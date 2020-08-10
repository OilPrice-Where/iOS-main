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
   @IBOutlet weak var brandSelectedSwitch: UISwitch!
   
   // 셀 설정
   func bind(brandSubject: Observable<String>) {
      selectionStyle = .none
      
      // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
      brandSubject
         .bind(to: brandTypeLable.rx.text)
         .disposed(by: rx.disposeBag)
      
      Observable.combineLatest(brandSubject, DefaultData.shared.brandsSubject)
         .map { $0.1.contains(Preferences.brand(name: $0.0)) }
         .bind(to: brandSelectedSwitch.rx.isOn)
         .disposed(by: rx.disposeBag)
      
      if brandTypeLable.text == "전체" {
         brandSelectedSwitch.isUserInteractionEnabled = !brandSelectedSwitch.isOn
         
         DefaultData.shared.brandsSubject
            .map { $0.count < 10 }
            .map { !$0 }
            .bind(to: brandSelectedSwitch.rx.isOn)
            .disposed(by: rx.disposeBag)
      } else {
         brandSelectedSwitch.rx.isOn
            .subscribe(onNext: { [weak self] in
               guard let strongSelf = self,
                  var brands = try? DefaultData.shared.brandsSubject.value(),
                  let name = strongSelf.brandTypeLable.text else { return }
               
               let code = Preferences.brand(name: name)
               
               if $0 {
                  if !brands.contains(code) { brands.append(code) }
               } else {
                  brands = brands.filter { $0 != code }
               }
               
               DefaultData.shared.brandsSubject.onNext(brands)
            })
            .disposed(by: rx.disposeBag)
      }
   }
}
