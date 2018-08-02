//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 25..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class GasStationCell: UITableViewCell {

    @IBOutlet private weak var name : UILabel!
    @IBOutlet private weak var price : UILabel!
    @IBOutlet private weak var distance : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // 메뉴 명, 설명, 가격, 이미지 삽입
    func configure(with gasStation: GasStation) {
        let distanceKM = gasStation.distance / 1000
        
        self.name.text = gasStation.name
        self.price.text = String(gasStation.price)
        self.distance.text = String(distanceKM.roundTo(places: 2)) + "km"
    }

}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
