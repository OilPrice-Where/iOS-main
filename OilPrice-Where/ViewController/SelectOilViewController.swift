//
//  SelectOilViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectOilViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SelectOilViewController"
   @IBOutlet private weak var tableView: UITableView!
   var viewModel: SelectOilTypeViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      self.navigationController?.navigationItem.leftBarButtonItem?.tintColor = .white
   }
   
   func bindViewModel() {
      viewModel.oilSubject
         .bind(to: tableView.rx.items(cellIdentifier: OilTypeTableViewCell.identifier,
                                      cellType: OilTypeTableViewCell.self)) { index, type, cell in
                                       cell.configure(typeName: type)
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.modelSelected(String.self)
         .subscribe(onNext: {
            let type = Preferences.oil(name: $0)
            DefaultData.shared.oilSubject.onNext(type)
         })
         .disposed(by: rx.disposeBag)
   }
}
