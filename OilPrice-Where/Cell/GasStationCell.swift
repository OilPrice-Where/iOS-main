//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 25..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class GasStationCell: UITableViewCell {

    @IBOutlet weak var stationView : GasStationView!
    let path = UIBezierPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stationView.favoriteButton.layer.cornerRadius = 6
        stationView.annotationButton.layer.cornerRadius = 6
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationView.stackView.isHidden = true
    }
    
    // 메뉴 명, 설명, 가격, 이미지 삽입
    func configure(with gasStation: GasStation) {
        self.stationView.configure(with: gasStation)
        self.stationView.layer.borderColor = UIColor.lightGray.cgColor.copy(alpha: 0.5)
        self.stationView.layer.borderWidth = 1
        self.stationView.layer.cornerRadius = 6
//        self.stationView.layer.shadowRadius = 2
//        self.stationView.layer.shadowColor = UIColor.black.cgColor
//        self.stationView.layer.shadowOpacity = 0.5
//        path.move(to: CGPoint(x:0, y: self.stationView.bounds.height))
//        path.addLine(to: CGPoint(x: self.stationView.bounds.width,
//                                 y: self.stationView.bounds.height))
//        path.addLine(to: CGPoint(x: self.stationView.bounds.width,
//                                 y: 0))
//        self.stationView.layer.shadowPath = self.path.cgPath
    }

//    func animateView(<#parameters#>) -> <#return type#> {
//        <#function body#>
//    }
}

extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
