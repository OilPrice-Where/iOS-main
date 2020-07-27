//
//  DetailView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import SCLAlertView

class DetailView: UIView {
   
   var id: String! // Station ID
   @IBOutlet weak var logoType : UIImageView! // Logo
   @IBOutlet weak var stationName : UILabel! // 주유소 명
   @IBOutlet weak var distance : UILabel! // 거리
   @IBOutlet weak var oilPrice : UILabel! // 기름 가격
   @IBOutlet weak var oilType : UILabel! // 기름 타입
   @IBOutlet weak var detailViewBottomConstraint: NSLayoutConstraint! // Detail View Bottom Constraint
   @IBOutlet weak var favoriteButton : UIButton! // Favorite Button
   @IBOutlet weak var navigationStartButtonView : UIView! // Navigation Start Button
   @IBOutlet weak var navigationImageView : UIImageView! // Navigation Start Button 내부 Image View
   @IBOutlet weak var navigationLabel : UILabel! // Navigation Start Button 내부 Label
   var tapGesture: UITapGestureRecognizer! // Navigation Start Button Tap Gesture
   
   // Detail View 기본 설정
   func configure(_ info: GasStation) {
      let kmDistance = info.distance / 1000 // M -> KM (단위 계산)
      
      self.id = info.id // 주유소 ID 설정
      self.logoType.image = Preferences.logoImage(logoName: info.brand) // 로고이미지 설정
      
      // 주유소명 설정
      self.stationName.text = info.name
      self.stationName.font = UIFont(name: "NanumSquareRoundB", size: 20)
      
      // 거리 설정
      self.distance.text = String(kmDistance.roundTo(places: 2)) + "km"
      self.distance.font = UIFont(name: "NanumSquareRoundB", size: 10)
      
      // 오일 가격 설정
      self.oilPrice.text = Preferences.priceToWon(price: info.price)
      self.oilPrice.font = UIFont(name: "NanumSquareRoundEB", size: 33)
      
      // 오일 타입 설정
      DefaultData.shared.oilSubject
         .map { Preferences.oil(code: $0) }
         .bind(to: oilType.rx.text)
         .disposed(by: rx.disposeBag)
      
      self.oilType.font = UIFont(name: "NanumSquareRoundB", size: 14)
      
      // Detail View & Navigation Start Button View 외곽선 설정
      self.layer.cornerRadius = 6
      navigationStartButtonView.layer.cornerRadius = 6
      navigationStartButtonView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
      navigationStartButtonView.layer.borderWidth = 1.5
      
      // Favorite Button 외곽서 설정
      favoriteButton.layer.borderWidth = 1.5
      favoriteButton.layer.cornerRadius = 6 // 즐겨찾기 버튼 외곽선 Radius 값 설정
      favoriteButton.layer.borderColor = UIColor(named: "MainColor")!.cgColor
      
      // Favorite Button Event
      favoriteButton.addTarget(self, action: #selector(self.clickedEvent(_:)), for: .touchUpInside)
      favoriteButton.isSelected = false
      
      // 즐겨찾기 목록의 StationID 값과 StationView의 StationID 값이 동일 하면 선택 상태로 변경
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
   
   // Navigation Start Button View Tap Gesture
   func detailViewTapGestureRecognizer(target: Any, action: Selector) {
      tapGesture = UITapGestureRecognizer(target: target, action: action)
      navigationStartButtonView.addGestureRecognizer(tapGesture)
   }
   
   // Favorite Button Clicked Event
   @objc func clickedEvent(_ sender: UIButton) {
      guard var favArr = try? DefaultData.shared.favoriteSubject.value(), favArr.count < 5, let id = self.id else {
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
