//
//  SettingTableViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import SwiftyPlistManager

class SettingTableViewController: UITableViewController {
    
    @IBOutlet private weak var oilTypeLabel : UILabel!
    @IBOutlet private weak var findLabel : UILabel!
    var oilTypeName = Preferences.oil(code: DefaultData.shared.oilType)
    var findDistance = String(DefaultData.shared.radius / 1000) + "KM"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        oilTypeLabel.text = oilTypeName
        findLabel.text = findDistance
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "SelectOilType" {
            let controller = segue.destination as! SelectOilTypeTableViewController
            controller.selectedOilTypeName = self.oilTypeName
        } else if segue.identifier == "FindDistance" {
            let controller = segue.destination as! SelectFindDistanceTableViewController
            controller.selectedDistance = self.findDistance
        }
    }
    
    @IBAction private func didPickerOilType(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! SelectOilTypeTableViewController
        oilTypeName = controller.selectedOilTypeName
        oilTypeLabel.text = oilTypeName
        DefaultData.shared.oilType = Preferences.oil(name: oilTypeName)
    }
    
    @IBAction private func didPickerDistance(_ segue: UIStoryboardSegue) {
        let controller = segue.source as! SelectFindDistanceTableViewController
        findDistance = controller.selectedDistance
        findLabel.text = findDistance
        DefaultData.shared.radius = Preferences.distanceKM(KM: findDistance)
    }
}
