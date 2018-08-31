//
//  NoticeDetailViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 31/08/2018.
//  Copyright © 2018 sangwook park. All rights reserved.
//

import UIKit

class NoticeDetailViewController: UIViewController {
    
    @IBOutlet weak var detailTitleLabel: UILabel!
    @IBOutlet weak var contentTextView: UITextView!
    
    var titleText: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTitleLabel.textColor = UIColor.white
        detailTitleLabel.text = titleText
        print("**************************************\(titleText)")
        
        navigationItem.leftBarButtonItem?.tintColor = UIColor.white
        navigationSetting()
        contentTextView.layer.cornerRadius = 6
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        detailTitleLabel.text = titleText
    }
    

    func navigationSetting() {
        let backButtonItem = UIBarButtonItem()
        backButtonItem.title = ""
        backButtonItem.tintColor = UIColor.white
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButtonItem
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.font: UIFont(name: "NanumSquareRoundEB", size: 18)!, NSAttributedStringKey.foregroundColor: UIColor.white]
    }

    
}
