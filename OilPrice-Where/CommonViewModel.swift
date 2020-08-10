//
//  CommonViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation

enum NaviType: String {
   case kakao = "kakao"
   case tMap = "tmap"
}

class CommonViewModel: NSObject {
   var storyboard = UIStoryboard(name: "Main", bundle: nil)
}
