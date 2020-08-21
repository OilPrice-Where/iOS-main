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

extension SettingEditSalePriceViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      return 60
   }
   
   func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
      let label = UILabel(frame: CGRect(x: 17, y: 35, width: tableView.bounds.width - 16, height: 20))
      label.text = "소유한 카드의 리터당 할인정보 입력"
      label.font = UIFont(name: "NanumSquareRoundR", size: 13)
      label.textAlignment = .left
      label.textColor = .darkGray
      
      view.addSubview(label)
      
      return view
   }
}
