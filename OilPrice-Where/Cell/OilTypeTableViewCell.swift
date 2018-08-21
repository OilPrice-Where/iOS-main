//
//  OilTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 설정 탭 내부의 오일 종류 관련 셀
class OilTypeTableViewCell: UITableViewCell {

    @IBOutlet private weak var oilTypeLabel : UILabel! // 오일 종류
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    // 셀 설정
    func configure(typeName: String) {
        oilTypeLabel.text = typeName // 오일의 종류에 따라 셀에 뿌린다
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
