//
//  FindDistanceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 10..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

// 설정 -> 탐색 반경 선택 리스트 셀
class FindDistanceTableViewCell: UITableViewCell {
   static let identifier = "FindDistanceTableViewCell"
   @IBOutlet weak var distanceLabel: UILabel! // 탐색 반경 레이블
   
   // 셀 설정
   func configure(distance: String) {
      selectionStyle = .none
      distanceLabel.text = distance // 탐색 반경 리스트(1,3,5KM)를 셀에 표시
      
      DefaultData.shared.radiusSubject
         .subscribe(onNext: {
            let radius = Preferences.distanceKM(KM: distance)
            self.accessoryType = $0 == radius ? .checkmark : .none
         })
         .disposed(by: rx.disposeBag)
   }
}
