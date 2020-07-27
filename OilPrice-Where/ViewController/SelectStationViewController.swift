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
   @IBOutlet private weak var tableView: UITableView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.brandSubject
         .bind(to: tableView.rx.items(cellIdentifier: BrandTypeTableViewCell.identifier,
                                      cellType: BrandTypeTableViewCell.self)) { index, brand, cell in
                                       cell.bind(brandSubject: Observable.just(brand))
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.modelSelected(String.self)
         .subscribe(onNext: {
            let code = Preferences.brand(name: $0)
            DefaultData.shared.brandSubject.onNext(code)
         })
         .disposed(by: rx.disposeBag)
   }
}
