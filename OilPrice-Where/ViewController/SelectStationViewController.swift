//
//  SelectStationViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

class SelectStationViewController: CommonViewController, ViewModelBindableType {
   var viewModel: SelectStationViewModel!
   @IBOutlet private weak var tableView: UITableView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.brandSubject
         .bind(to: tableView.rx.items(cellIdentifier: BrandTypeTableViewCell.identifier,
                                      cellType: BrandTypeTableViewCell.self)) { index, brand, cell in
                                       cell.configure(typeName: brand)
                                       
                                       if let brand = try? DefaultData.shared.brandSubject.value(),
                                       brand == Preferences.brand(name: brand) {
                                          cell.accessoryType = .checkmark
                                       } else {
                                          cell.accessoryType = .none
                                       }
                                       
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.itemSelected
         .subscribe(onNext: {
            guard let selectCell = self.tableView.cellForRow(at: $0) as? BrandTypeTableViewCell,
               let brand = selectCell.brandTypeLable.text else { fatalError() }
            let code = Preferences.brand(name: brand)
            
            DefaultData.shared.brandSubject.onNext(code)
         })
         .disposed(by: rx.disposeBag)
   }
}
