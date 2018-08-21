//
//  NoticeViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 2..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class NoticeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        
    }

    @IBAction func leftBarButton() {
        navigationController?.popViewController(animated: true)
        }
}
