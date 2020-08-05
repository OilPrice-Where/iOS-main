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
   var viewModel: InitialViewModel!
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet private weak var leftButton: UIButton!
   @IBOutlet private weak var rightButton: UIButton!
   @IBOutlet private weak var okButton : UIButton!
   
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .default
   }
   
   func viewLayoutSetUp() {
      okButton.layer.cornerRadius = 6
      
      if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
         layout.itemSize = collectionView.bounds.size
      }
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      viewLayoutSetUp()
      bindViewModel()
   }

   func bindViewModel() {
      viewModel.initialOilTypeSubject
         .bind(to: collectionView.rx.items(cellIdentifier: InitialCollectionViewCell.identifier,
                                           cellType: InitialCollectionViewCell.self)) { item, initialOilType, cell in
                                             cell.configure(initialOilType: initialOilType)
         }
         .disposed(by: rx.disposeBag)
      
      collectionView.rx.contentOffset
         .map { $0.x }
         .subscribe(onNext: {
            self.leftButton.isEnabled = !($0 <= 0)
            self.rightButton.isEnabled = !($0 >= self.collectionView.bounds.width * 3)
         })
         .disposed(by: rx.disposeBag)
      
      leftButton.rx.tap
         .map { self.collectionView.contentOffset }
         .map { CGPoint(x: $0.x - self.collectionView.bounds.width, y: $0.y) }
         .map { self.collectionView.indexPathForItem(at: $0) }
         .subscribe(onNext: {
            if let indexPath = $0 {
               self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
         })
         .disposed(by: rx.disposeBag)
      
      rightButton.rx.tap
         .map { self.collectionView.contentOffset }
         .map { CGPoint(x: $0.x + self.collectionView.bounds.width, y: $0.y) }
         .map { self.collectionView.indexPathForItem(at: $0) }
         .subscribe(onNext: {
            if let indexPath = $0 {
               self.collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            }
         })
         .disposed(by: rx.disposeBag)
      
      // 확인 버튼 클릭 이벤트
      okButton.rx.tap
         .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
         .map { self.collectionView.contentOffset.x / self.collectionView.bounds.width }
         .map { Int($0) }
         .map { (SelectInitialPage(rawValue: $0) ?? SelectInitialPage.gasoline) }
         .subscribe(onNext: { self.viewModel.okAction(page: $0) })
         .disposed(by: rx.disposeBag)
   }
}
