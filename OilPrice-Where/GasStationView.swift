//
//  GasStationView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 14..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SCLAlertView

// 메인페이지의 리스트의 셀 내부(ContentView)에 표시되는 뷰
// 스택뷰는 기본적으로 숨겨져 있으며 클릭시 스택뷰가 나타난다.
class GasStationView: UIView {
   // 기본 설정 관련
   @IBOutlet private weak var name : UILabel! // 주유소 명
   @IBOutlet private weak var price : UILabel! // 기름 가격
   @IBOutlet private weak var distance : UILabel! // 거리
   @IBOutlet private weak var oilType : UILabel! // 기름 타입
   @IBOutlet private weak var logo : UIImageView! // 로고(SK, GS, 알뜰 등..)
   var id: String?
   
   // Stack View
   @IBOutlet weak var stackView : UIStackView! // 내부 버튼(즐겨찾기, 경로 표시)을 가진 뷰(isHidden = true)
   @IBOutlet weak var favoriteButton : UIButton! // 즐겨 찾기 버튼
   @IBOutlet weak var annotationButtonView : UIView! // 경로 표시 버튼
   
   // 뷰 내부 설정
   func configure(with gasStation: GasStation) {
      let distanceKM = gasStation.distance / 1000 // m -> km 거리 계산
      
      id = gasStation.id // 주유소 ID 값 설정
      name.text = gasStation.name // 주유소 명 설정
      distance.text = String(distanceKM.roundTo(places: 2)) + "km" // 거리 설정
      logo.image = Preferences.logoImage(logoName: gasStation.brand) // 로고 이미지 삽입
      price.text = Preferences.priceToWon(price: gasStation.price) // 기름 가격 설정
      
      // annotationButtonView 외곽선 설정
      annotationButtonView.layer.cornerRadius = 6
      annotationButtonView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
      annotationButtonView.layer.borderWidth = 1.5
      
      // favoriteButton 외곽선 설정
      favoriteButton.layer.borderColor = UIColor(named: "MainColor")!.cgColor // 즐겨찾기 버튼 외곽선 컬러
      favoriteButton.layer.borderWidth = 1.5 // 즐겨찾기 버튼 외곽선 크기
      favoriteButton.layer.cornerRadius = 6 // 즐겨찾기 버튼 외곽선 Radius 값 설정
      
      // favoriteButton Action 설정
      favoriteButton.addTarget(self, action: #selector(clickedEvent(_:)), for: .touchUpInside)
      
      DefaultData.shared.oilSubject
         .map { Preferences.oil(code: $0) }
         .bind(to: oilType.rx.text)
         .disposed(by: rx.disposeBag)
      
      // 즐겨찾기 목록의 StationID 값과 StationView의 StationID값이 동일 하면 선택 상태로 변경
      DefaultData.shared.favoriteSubject
         .subscribe(onNext: {
            guard let id = self.id else { return }
            let image = $0.contains(id) ? UIImage(named: "favoriteOnIcon") : UIImage(named: "favoriteOffIcon")
            self.favoriteButton.setImage(image?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.favoriteButton.imageView?.tintColor = $0.contains(id) ? .white : UIColor(named: "MainColor")
            self.favoriteButton.backgroundColor = $0.contains(id) ? UIColor(named: "MainColor") : .white
         })
         .disposed(by: rx.disposeBag)
   }
   
   // Favorite Button Clicked Event
   @objc func clickedEvent(_ sender: UIButton) {
      guard var favArr = try? DefaultData.shared.favoriteSubject.value(), favArr.count < 5, let id = id else {
         if let favArr = try? DefaultData.shared.favoriteSubject.value(), let id = self.id, favArr.contains(id) {
            let newFavArr = favArr.filter { $0 != id }
            DefaultData.shared.favoriteSubject.onNext(newFavArr)
         } else {
            let appearance = SCLAlertView.SCLAppearance(
               kWindowWidth: 300,
               kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!,
               kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!,
               showCloseButton: false
            )
            
            let alert = SCLAlertView(appearance: appearance)
            alert.iconTintColor = UIColor.white
            let timeOut = SCLAlertView.SCLTimeoutConfiguration(timeoutValue: 1.5, timeoutAction: {})
            
            alert.showWarning("최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !", timeout: timeOut, colorStyle: 0x5E82FF)
         }
         return
      }
      
      // 즐겨찾기 설정 및 해제
      if favArr.contains(id) { // 즐겨찾기 해제
         let newFavArr = favArr.filter { $0 != id }
         DefaultData.shared.favoriteSubject.onNext(newFavArr)
      } else { // 즐겨찾기 설정
         favArr.append(id)
         DefaultData.shared.favoriteSubject.onNext(favArr)
      }
   }
}
