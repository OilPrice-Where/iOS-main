//
//  SelectNavigationController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectNavigationController: CommonViewController, ViewModelBindableType {
   static let identifier = "SelectNavigationController"
   @IBOutlet private weak var tableView: UITableView!
   var viewModel: SelectNaviViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.naviSubject
         .bind(to: tableView.rx.items(cellIdentifier: NavigaionTypeTableViewCell.identifier,
                                      cellType: NavigaionTypeTableViewCell.self)) { index, type, cell in
                                       cell.bind(naviSubject: Observable.just(type))
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.modelSelected(String.self)
         .subscribe(onNext: {
            let type = Preferences.navigationType(name: $0)
            DefaultData.shared.naviSubject.onNext(type)
         })
         .disposed(by: rx.disposeBag)
   }
}
