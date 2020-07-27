//
//  SelectDistanceViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SelectDistanceViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SelectDistanceViewController"
   var viewModel: SelectDistanceViewModel!
   @IBOutlet private weak var tableView: UITableView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      viewModel.distanceSubject
         .bind(to: tableView.rx.items(cellIdentifier: FindDistanceTableViewCell.identifier,
                                      cellType: FindDistanceTableViewCell.self)) { index, distance, cell in
                                       cell.configure(distance: distance)
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.modelSelected(String.self)
         .subscribe(onNext: {
            let radius = Preferences.distanceKM(KM: $0)
            DefaultData.shared.radiusSubject.onNext(radius)
         })
         .disposed(by: rx.disposeBag)
   }
}
