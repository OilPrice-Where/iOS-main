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

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
