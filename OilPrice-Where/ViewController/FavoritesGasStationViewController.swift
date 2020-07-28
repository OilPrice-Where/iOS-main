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
      DefaultData.shared.favoriteSubject
         .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.identifier,
                                           cellType: FavoriteCollectionViewCell.self)) { index, id, cell in
                                             cell.layer.cornerRadius = 35
                                             cell.activityIndicator.startAnimating()
                                             if let info = DefaultData.shared.tempFavArr[id] {
                                                cell.configure(with: info)
                                                cell.activityIndicator.stopAnimating()
                                             } else {
                                                self.viewModel.getStationsInfo(id: id) {
                                                   DefaultData.shared.tempFavArr[id] = $0
                                                   cell.configure(with: $0)
                                                   cell.activityIndicator.stopAnimating()
                                                }
                                             }
      }
      .disposed(by: rx.disposeBag)
   }
   
   @IBAction func pageChanged(_ sender: UIPageControl) {
      fromTap = true
      
      let indexPath = IndexPath(item: sender.currentPage, section: 0)
      collectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
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
