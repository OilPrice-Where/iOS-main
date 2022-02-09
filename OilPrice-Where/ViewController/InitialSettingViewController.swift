//
//  InitialSettingViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 19.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

// 초기 설정 페이지
class InitialSettingViewController: CommonViewController {
   typealias selectTypes = (oil: Int, navi: Int, map: Int)
   
   var viewModel: InitialViewModel!
   @IBOutlet private weak var selectTypeView: UIView!
   @IBOutlet private weak var oilTypeSegmentControl: UISegmentedControl!
   @IBOutlet private weak var naviTypeSegmentControl: UISegmentedControl!
   @IBOutlet private weak var mapTypeSegmentControl: UISegmentedControl!
   @IBOutlet private weak var okButton: UIButton!
   
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .default
   }
   
   func viewLayoutSetUp() {
      selectTypeView.layer.cornerRadius = 7.5
      okButton.layer.cornerRadius = 15
      
      let font = UIFont(name: "NanumSquareRoundR", size: 15) ?? UIFont.systemFont(ofSize: 17)

      let normalAttribute: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
      let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
      
      oilTypeSegmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
      oilTypeSegmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
      naviTypeSegmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
      naviTypeSegmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
      mapTypeSegmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
      mapTypeSegmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      viewLayoutSetUp()
      bindViewModel()
   }

   func bindViewModel() {
      // 확인 버튼 클릭 이벤트
      okButton.rx.tap
         .map { [weak self] _ -> selectTypes in
            guard let strongSelf = self else { return (oil: 0, navi: 0, map: 0) }
            return (oil: strongSelf.oilTypeSegmentControl.selectedSegmentIndex,
                    navi: strongSelf.naviTypeSegmentControl.selectedSegmentIndex,
                    map: strongSelf.mapTypeSegmentControl.selectedSegmentIndex)
         }
      .subscribe(onNext: { self.viewModel.okAction(oil: $0.oil, navi: $0.navi, map: $0.map) })
      .disposed(by: rx.disposeBag)
   }
}
