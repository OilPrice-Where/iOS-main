//
//  SalePriceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SalePriceTableViewCell: UITableViewCell {
   static let identifier = "SalePriceTableViewCell"
   @IBOutlet weak var salePriceTextField: UITextField!
   @IBOutlet private weak var brandImageView: UIImageView!
   @IBOutlet private weak var brandLabel: UILabel!
   
   func bind(targetSubject: Observable<BrandInfomation>) {
      targetSubject
         .map { $0.logo }
         .bind(to: brandImageView.rx.image)
         .disposed(by: rx.disposeBag)
      
      targetSubject
         .map { $0.title }
         .bind(to: brandLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      targetSubject
         .map { Preferences.saleBrand(name: $0.title) }
         .map { key -> String? in
            guard let dic = try? DefaultData.shared.salesSubject.value(),
               let value = dic[key] else { return nil }
            
            return value == 0 ? nil : "\(value)"
      }
      .bind(to: salePriceTextField.rx.text)
      .disposed(by: rx.disposeBag)
   }
   
   deinit {
      if var dic = try? DefaultData.shared.salesSubject.value(), let name = brandLabel.text {
         guard let value = salePriceTextField.text?.count == 0 ? 0 : Int(salePriceTextField.text ?? "0") else { return }
         
         let code = Preferences.saleBrand(name: name)
         
         guard dic[code] != value else { return }
         
         dic[code] = value
         DefaultData.shared.salesSubject.onNext(dic)
      }
   }
}
