//
//  FavoritesGasStationViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import CenteredCollectionView

class FavoritesGasStationViewController: CommonViewController {
   var viewModel = FavoriteViewModel()
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet weak var pager: UIPageControl! // Page Controller
   var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
   var fromTap = false
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
      collectionView.decelerationRate = UIScrollViewDecelerationRateFast
      
      centeredCollectionViewFlowLayout.minimumLineSpacing = 25
      centeredCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 75, height: 410)
      bindViewModel()
   }
   
   // Status Bar Color
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
   func bindViewModel() {
      pager.currentPage = 0 // 초기 Current Page
      viewModel.favoriteArrSubject
         .map { $0.count }
         .bind(to: pager.rx.numberOfPages)
         .disposed(by: rx.disposeBag)
      
      viewModel.favoriteArrSubject
         .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.identifier,
                                           cellType: FavoriteCollectionViewCell.self)) { index, info, cell in
                                             cell.configure(with: info)
                                             cell.layer.cornerRadius = 35
      }
      .disposed(by: rx.disposeBag)
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
