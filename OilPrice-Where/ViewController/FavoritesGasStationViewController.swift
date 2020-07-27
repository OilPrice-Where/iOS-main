//
//  FavoritesGasStationViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation
import RxSwift
import RxCocoa
import NSObject_Rx
import SCLAlertView
import CenteredCollectionView

class FavoritesGasStationViewController: CommonViewController {
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet weak var pager: UIPageControl! // Page Controller
   var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
   var fromTap = false
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
      collectionView.decelerationRate = UIScrollViewDecelerationRateFast
      
      centeredCollectionViewFlowLayout.minimumLineSpacing = 25
      centeredCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 20, height: 410)
      
      configure()
      defaultSetting() // 초기 설정
   }
   
   // Status Bar Color
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      if Reachability.isConnectedToNetwork() {
      } else {
         pager.numberOfPages = 0 // Page Number
         let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 300,
            kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!,
            kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!,
            showCloseButton: true
         )
         
         let alert = SCLAlertView(appearance: appearance)
         
         alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
         alert.iconTintColor = UIColor.white
      }
   }
   
   // 초기 설정
   func defaultSetting() {
      pager.currentPage = 0 // 초기 Current Page
      DefaultData.shared.favoriteSubject
         .map { $0.count }
         .bind(to: pager.rx.numberOfPages)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.favoriteSubject
         .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.identifier,
                                           cellType: FavoriteCollectionViewCell.self)) { index, id, cell in
         ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                          id: id) { (result) in
            switch result {
            case .success(let info):
               cell.configure(with: info.result.allPriceList[0])
            case .error(let err):
               print(err.localizedDescription)
            }
         }
      }
      .disposed(by: rx.disposeBag)
   }
   
   func configure() {
      let scale: CGFloat = 0.6
      pager.transform = CGAffineTransform(scaleX: scale, y: scale)
      
      for dot in pager.subviews {
         dot.transform = CGAffineTransform(scaleX: scale, y: scale)
      }
   }
   
   @IBAction func pageChanged(_ sender: UIPageControl) {
      fromTap = true
      
      let indexPath = IndexPath(item: sender.currentPage, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
   }
}

//MARK: Page Control / ScrollView Delegate
extension FavoritesGasStationViewController: UIScrollViewDelegate {
   func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
      fromTap = false
      pager.updateCurrentPageDisplay()
      
   }
   
   func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard !fromTap else { return }
      if let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage {
         if pager.currentPage != currentCenteredPage {
            pager.currentPage = currentCenteredPage
         }
      }
   }
}

//MARK: UICollectionView Delegate
extension FavoritesGasStationViewController: UICollectionViewDelegateFlowLayout {
}

extension FavoritesGasStationViewController: UICollectionViewDelegate {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
     let currentCenteredPage = centeredCollectionViewFlowLayout.currentCenteredPage
      
     if currentCenteredPage != indexPath.item {
       centeredCollectionViewFlowLayout.scrollToPage(index: indexPath.item, animated: true)
     }
   }
}
