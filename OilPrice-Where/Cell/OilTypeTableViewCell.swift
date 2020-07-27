//
//  OilTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 설정 -> 오일 타입 선택 리스트 셀
class OilTypeTableViewCell: UITableViewCell {
   static let identifier = "OilTypeTableViewCell"
   @IBOutlet weak var oilTypeLabel : UILabel! // 오일 종류

   // 셀 설정
   func configure(typeName: String) {
      selectionStyle = .none
      oilTypeLabel.text = typeName // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
      
      DefaultData.shared.oilSubject
         .subscribe(onNext: {
            let type = Preferences.oil(code: $0)
            self.accessoryType = type == typeName ? .checkmark : .none
         })
         .disposed(by: rx.disposeBag)
   }
}
