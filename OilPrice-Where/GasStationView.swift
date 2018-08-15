//
//  GasStationView.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class GasStationView: UIView {

    @IBOutlet private weak var name : UILabel!
    @IBOutlet private weak var price : UILabel!
    @IBOutlet private weak var distance : UILabel!
    @IBOutlet private weak var oilType : UILabel!
    @IBOutlet private weak var logo : UIImageView!
    @IBOutlet weak var stackView : UIStackView!
    
    func configure(with gasStation: GasStation) {
        let distanceKM = gasStation.distance / 1000
        
        self.name.text = gasStation.name
        self.distance.text = String(distanceKM.roundTo(places: 2)) + "km"
        self.logo.image = Preferences.logoImage(logoName: gasStation.brand)
        self.oilType.text = Preferences.oil(code: DefaultData.shared.oilType)
        if gasStation.price >= 1000 {
            self.price.text = String(gasStation.price / 1000) + "," + String(gasStation.price % 1000)
        } else {
            self.price.text = String(gasStation.price)
        }
    }
}
