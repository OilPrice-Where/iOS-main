//
//  OilTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class OilTypeTableViewCell: UITableViewCell {

    @IBOutlet private weak var oilTypeLabel : UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(typeName: String) {
        oilTypeLabel.text = typeName
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
