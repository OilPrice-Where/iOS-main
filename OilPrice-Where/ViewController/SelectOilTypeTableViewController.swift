//
//  SelectOilTypeTableViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class SelectOilTypeTableViewController: UITableViewController {

    var selectedOilTypeName = ""
    var selectIndexPath:IndexPath?
    
    let OilType = [
    "휘발유",
    "고급휘발유",
    "경유",
    "실내등유",
    "자동차부탄"
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for i in 0..<OilType.count {
            if OilType[i] == selectedOilTypeName {
                selectIndexPath = IndexPath(row: i, section: 0)
                break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! OilTypeTableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            selectedOilTypeName = OilType[indexPath.row]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return OilType.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "OilTypeCell", for: indexPath) as! OilTypeTableViewCell
        
        let oilTypeName = OilType[indexPath.row]
        cell.configure(typeName: oilTypeName)
        
        if oilTypeName == selectedOilTypeName {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectIndexPath = selectIndexPath else { return }
        if indexPath.row != selectIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectIndexPath) {
                oldCell.accessoryType = .none
            }
            self.selectIndexPath = indexPath
        }
    }
}
