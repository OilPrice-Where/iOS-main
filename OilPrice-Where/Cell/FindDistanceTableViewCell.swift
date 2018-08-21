//
//  FindDistanceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 10..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class FindDistanceTableViewCell: UITableViewCell {

    @IBOutlet private weak var distanceLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(distance: String) {
        distanceLabel.text = distance
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
