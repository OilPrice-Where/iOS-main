//
//  GasStationView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 메인페이지의 리스트의 셀 내부(ContentView)에 표시되는 뷰
// 스택뷰는 기본적으로 숨겨져 있으며 클릭시 스택뷰가 나타난다.
class GasStationView: UIView {

    // 기본 설정 관련
    @IBOutlet private weak var name : UILabel! // 주유소 명
    @IBOutlet private weak var price : UILabel! // 기름 가격
    @IBOutlet private weak var distance : UILabel! // 거리
    @IBOutlet private weak var oilType : UILabel! // 기름 타입
    @IBOutlet private weak var logo : UIImageView! // 로고(SK, GS, 알뜰 등..)
    
    // Stack View
    @IBOutlet weak var stackView : UIStackView! // 내부 버튼(즐겨찾기, 경로 표시)을 가진 뷰(isHidden = true)
    @IBOutlet weak var favoriteButton : UIButton! // 즐겨 찾기 버튼
    @IBOutlet weak var annotationButtonView : UIView! // 경로 표시 버튼
    
    // 뷰 내부 설정
    func configure(with gasStation: GasStation) {
        let distanceKM = gasStation.distance / 1000 // m -> km 거리 계산
        
        self.name.text = gasStation.name // 주유소 명 설정
        self.distance.text = String(distanceKM.roundTo(places: 2)) + "km" // 거리 설정
        self.logo.image = Preferences.logoImage(logoName: gasStation.brand) // 로고 이미지 삽입
        self.oilType.text = Preferences.oil(code: DefaultData.shared.oilType) // 오일 타입 설정
        self.price.text = Preferences.priceToWon(price: gasStation.price) // 기름 가격 설정
    }
}
