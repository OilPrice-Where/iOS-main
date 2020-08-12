//
//  SettingEditSalePriceViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

class SettingEditSalePriceViewController: CommonViewController, ViewModelBindableType {
   static let identifier = "SettingEditSalePriceViewController"
   @IBOutlet private weak var tableView: UITableView!
   var viewModel: EditSalePriceViewModel!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
   
   func bindViewModel() {
      
   }
}
