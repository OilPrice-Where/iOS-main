//
//  SelectStationViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectStationViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SelectStationViewController"
   var viewModel: SelectStationViewModel!
   var isAllSwitchButton = BehaviorSubject<Bool?>(value: nil)
   @IBOutlet private weak var tableView: UITableView!
   let allBrands = ["SOL", "RTX", "ETC", "SKE", "GSC", "HDO", "RTO", "NHO", "E1G", "SKG"]
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.brandSubject
         .bind(to: tableView.rx.items(cellIdentifier: BrandTypeTableViewCell.identifier,
                                      cellType: BrandTypeTableViewCell.self)) { index, brand, cell in
         cell.bind(brandSubject: Observable.just(brand))
         if brand == "전체" {
            cell.brandSelectedSwitch.rx.isOn
               .subscribe(onNext: { self.isAllSwitchButton.onNext($0) })
               .disposed(by: self.rx.disposeBag)
         } else {
            self.isAllSwitchButton
               .subscribe(onNext: {
                  if let isOn = $0 {
                     cell.brandSelectedSwitch.isOn = isOn
                     DefaultData.shared.brandsSubject.onNext(isOn ? self.allBrands : [])
                  }
               })
               .disposed(by: self.rx.disposeBag)
         }
      }
      .disposed(by: rx.disposeBag)
   }
}

extension SelectStationViewController: UITableViewDelegate {
}
