//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation

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
        
        let destination = KNVLocation(name: "Test", x: 321286, y: 533707)
        let options = KNVOptions()
        
        let params = KNVParams(destination: destination,
                               options: options)
        KNVNaviLauncher.shared().navigate(with: params)
        
    }
    
    func configure(with gasStation: GasStation) {
//        let distanceKM = gasStation.distance / 1000
        
        
        self.gasStationNameLabel.text = gasStation.name
        self.oilPlice.text = String(gasStation.price)
        
//        self.distance.text = String(distanceKM.roundTo(places: 2)) + "km"
    }

  
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    
}
