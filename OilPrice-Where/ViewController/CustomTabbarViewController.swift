//
//  CustomTabbarViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SCLAlertView

class CustomTabbarViewController: UITabBarController {
   override func viewDidLoad() {
      super.viewDidLoad()
      
      // 네트워크 사용 불가능 상태 일 때
      DefaultData.shared.reachability?.whenUnreachable = { _ in
         // Alert 설정
         let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 300, // Alert Width
            kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!, // Alert Title Font
            kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!, // Alert Content Font
            showCloseButton: true // CloseButton isHidden = True
         )
         
         let alert = SCLAlertView(appearance: appearance)
         alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
         alert.iconTintColor = UIColor.white
      }
   }
}
