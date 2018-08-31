//
//  NoticeTableViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 31/08/2018.
//  Copyright © 2018 sangwook park. All rights reserved.
//

import UIKit

class NoticeTableViewController: UITableViewController {
    
    let noticeList:[String] = ["공지사항", "1111111"]
    var notice = "" // 선택한 공지사항
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "NanumSquareRoundEB", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor.white]
        
        tableView.reloadData()
        
    }
    
    // MARK: - Table view data source
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return noticeList.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NoticeTableViewCell
        
        cell.titleLabel.text = noticeList[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    var selectedIndex = 0
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        print("You selected cell \(indexPath.row)")
        
        let currentCell = tableView.cellForRow(at: indexPath) as! NoticeTableViewCell
        print("currentCell************\(currentCell)")
        notice = currentCell.titleLabel.text!
        
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "NoticeSegue" {
            
            
            if let vc = segue.destination as? NoticeDetailViewController {
                vc.titleText = self.notice
            }
        }
    }
}

