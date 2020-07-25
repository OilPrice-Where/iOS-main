//
//  BrandTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박소정 on 03/01/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit

class BrandTypeTableViewCell: UITableViewCell {
   static let identifier = "BrandTypeTableViewCell"
   @IBOutlet weak var brandTypeLable : UILabel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      // Initialization code
   }
   
   // 셀 설정
   func configure(typeName: String) {
      brandTypeLable.text = typeName // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
   }
   
   override func setSelected(_ selected: Bool, animated: Bool) {
      super.setSelected(selected, animated: animated)
      
      // Configure the view for the selected state
   }
   
}
