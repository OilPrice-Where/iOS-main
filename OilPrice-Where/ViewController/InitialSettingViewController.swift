//
//  InitialSettingViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱n 2018. 8. 19..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 초기 설정 페이지
class InitialSettingViewController: CommonViewController {
   
   @IBOutlet private weak var scrollView : UIScrollView! // 페이지 표시 스크롤 뷰
   lazy var scrollWidth = scrollView.bounds.size.width // 스크롤 뷰의 Width값 저장
   @IBOutlet private weak var okButton : UIButton!
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      okButton.layer.cornerRadius = 6
   }
   
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .default
   }
   
   // 확인 버튼 클릭 이벤트
   @IBAction private func okAction(_ sender: UIButton) {
      let selectedPage = scrollView.bounds.origin.x / scrollWidth // 선택한 오일 종류
      var selectedOil = ""
      switch selectedPage {
      case 1:
         selectedOil = "D047" // 두번째 페이지 선택 경유
      case 2:
         selectedOil = "K015" // 세번째 페이지 선택 LPG
      case 3:
         selectedOil = "B034" // 네번째 페이지 선택 고급휘발유
      default:
         selectedOil = "B027" // 첫번째 페이지 선택 휘발유
      }
      
      DefaultData.shared.oilSubject.onNext(selectedOil)
   }
   
   // 왼쪽 버튼 클릭 이벤트
   // 왼쪽 버튼 클릭 시 이전 페이지로 이동
   @IBAction private func leftAction(_ sender: UIButton) {
      if scrollView.contentOffset.x > 0 {
         UIView.animate(withDuration: 0.2) {
            self.scrollView.contentOffset.x -= self.scrollWidth
         }
      }
   }
   
   // 오른쪽 버튼 클릭 이벤트
   // 오른쪽 버튼 클릭 시 다음 페이지로 이동
   @IBAction private func rightAction(_ sender: UIButton) {
      if scrollView.contentOffset.x < scrollWidth * 3 {
         UIView.animate(withDuration: 0.2) {
            self.scrollView.contentOffset.x += self.scrollWidth
         }
      }
   }
}
