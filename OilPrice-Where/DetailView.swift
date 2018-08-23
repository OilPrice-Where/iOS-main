//
//  DetailView.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class DetailView: UIView {

    @IBOutlet weak var logoType : UIImageView! // Logo
    @IBOutlet weak var stationName : UILabel! // 주유소 명
    @IBOutlet weak var distance : UILabel! // 거리
    @IBOutlet weak var oilPrice : UILabel! // 기름 가격
    @IBOutlet weak var oilType : UILabel! // 기름 타입
    @IBOutlet weak var detailViewBottomConstraint: NSLayoutConstraint! // Detail View Bottom Constraint

}
