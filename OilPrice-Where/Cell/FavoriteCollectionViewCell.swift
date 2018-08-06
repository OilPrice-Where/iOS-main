//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
class FavoriteCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "FavoriteCollectionViewCell"
    
    // 이미지
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var carWashImageView: UIImageView!
    @IBOutlet weak var repairShopImageView: UIImageView!
    @IBOutlet weak var convenienceStoreImageView: UIImageView!
    
    // 레이블
    @IBOutlet weak var gasStationNameLabel: UILabel!
     @IBOutlet weak var carWashLabel: UILabel!
     @IBOutlet weak var repairShopLabel: UILabel!
     @IBOutlet weak var convenienceStoreLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var qualityCertificationLabel: UILabel!
    
    @IBOutlet weak var typeOfOilLabel: UILabel!
    @IBOutlet weak var oilPlice: UILabel!
    
    //버튼
    @IBAction func navigationButton(_ sender: UIButton) {
        
    }
    
    
}
