//
//  headerView.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class MainHeaderView: UIView {

    @IBOutlet private weak var geoLabel : UILabel!
    
    func configure(with geoCode: String) {
        geoLabel.text = geoCode
    }

}
