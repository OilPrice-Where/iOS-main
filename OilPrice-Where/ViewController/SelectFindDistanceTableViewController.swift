//
//  SelectFindDistanceTableViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class SelectFindDistanceTableViewController: UITableViewController {

    var selectedDistance = ""
    var selectedIndexPath: IndexPath?
    let findDistaceArea = [
    "1KM",
    "3KM",
    "5KM"
    ]
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! FindDistanceTableViewCell
        if let indexPath = tableView.indexPath(for: cell) {
            self.selectedDistance = findDistaceArea[indexPath.row]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for i in 0 ..< findDistaceArea.count {
            if selectedDistance == findDistaceArea[i] {
                selectedIndexPath = IndexPath(row: i, section: 0)
            }
        }
    }
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return findDistaceArea.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FindDistance", for: indexPath) as! FindDistanceTableViewCell
        
        let findDistance = findDistaceArea[indexPath.row]
        cell.configure(distance: findDistance)
        
        if selectedDistance == findDistance {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectIndexPath = selectedIndexPath else { return }
        if indexPath.row != selectIndexPath.row {
            if let newCell = tableView.cellForRow(at: indexPath) {
                newCell.accessoryType = .checkmark
            }
            if let oldCell = tableView.cellForRow(at: selectIndexPath) {
                oldCell.accessoryType = .none
            }
            self.selectedIndexPath = indexPath
        }
    }
}
