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
   }
   
   func bindViewModel() {
      viewModel.oilSubject
         .bind(to: tableView.rx.items(cellIdentifier: OilTypeTableViewCell.identifier,
                                      cellType: OilTypeTableViewCell.self)) { index, type, cell in
                                       cell.configure(typeName: type)
                                       
                                       if let oilType = try? DefaultData.shared.oilSubject.value(),
                                          oilType == type {
                                          cell.accessoryType = .checkmark
                                       } else {
                                          cell.accessoryType = .none
                                       }
                                       
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.itemSelected
         .subscribe(onNext: {
            guard let selectCell = self.tableView.cellForRow(at: $0) as? OilTypeTableViewCell,
               let type = selectCell.oilTypeLabel.text else { fatalError() }
            
            DefaultData.shared.oilSubject.onNext(type)
         })
         .disposed(by: rx.disposeBag)
   }
}
