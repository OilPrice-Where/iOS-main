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
                                       
                                       if let radius = try? DefaultData.shared.radiusSubject.value(),
                                       radius == Preferences.distanceKM(KM: distance) {
                                          cell.accessoryType = .checkmark
                                       } else {
                                          cell.accessoryType = .none
                                       }
                                       
      }
      .disposed(by: rx.disposeBag)
      
      tableView.rx.itemSelected
         .subscribe(onNext: {
            guard let selectCell = self.tableView.cellForRow(at: $0) as? FindDistanceTableViewCell,
               let distance = selectCell.distanceLabel.text else { fatalError() }
            let radius = Preferences.distanceKM(KM: distance)
            
            DefaultData.shared.radiusSubject.onNext(radius)
         })
         .disposed(by: rx.disposeBag)
   }
}
