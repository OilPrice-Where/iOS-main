//
//  SelectMapsViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/08/21.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectMapsViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SelectMapsViewController"
   @IBOutlet private weak var tableView: UITableView!
   var viewModel: SelectMapsViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.mapSubject
         .bind(to: tableView.rx.items(cellIdentifier: MapTypeTableViewCell.identifier,
                                      cellType: MapTypeTableViewCell.self)) { index, type, cell in
                                       cell.bind(mapSubject: Observable.just(type))
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.modelSelected(String.self)
         .subscribe(onNext: {
            let type = Preferences.mapsType(name: $0)
            DefaultData.shared.mapsSubject.onNext(type)
         })
         .disposed(by: rx.disposeBag)
   }
}
