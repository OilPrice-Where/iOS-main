//
//  SettingEditSalePriceViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SettingEditSalePriceViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SettingEditSalePriceViewController"
   @IBOutlet private weak var tableView: UITableView!
   var viewModel: EditSalePriceViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      tableView.keyboardDismissMode = .onDrag
      
      let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction))
      tableView.addGestureRecognizer(tap)
   }
   
   @objc func handleTapAction() {
      tableView.endEditing(true)
   }
   
   func bindViewModel() {
      viewModel.brandsInfoSubject
         .bind(to: tableView.rx.items(cellIdentifier: SalePriceTableViewCell.identifier,
                                      cellType: SalePriceTableViewCell.self)) { item, info, cell in
                                       cell.bind(targetSubject: Observable.just(info))
                                       cell.selectionStyle = .none
      }
      .disposed(by: rx.disposeBag)
   }
}
