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
   var reachability: Reachability? = Reachability() //Network
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet private weak var noneFavoriteView: UIView!
   var centeredCollectionViewFlowLayout: CenteredCollectionViewFlowLayout!
   var fromTap = false
   
   // Status Bar Color
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
   deinit {
      reachability?.stopNotifier()
      reachability = nil
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      setNetworkSetting()
      centeredCollectionViewFlowLayout = (collectionView.collectionViewLayout as! CenteredCollectionViewFlowLayout)
      collectionView.decelerationRate = UIScrollViewDecelerationRateFast
      
      centeredCollectionViewFlowLayout.minimumLineSpacing = 25
      centeredCollectionViewFlowLayout.itemSize = CGSize(width: UIScreen.main.bounds.width - 75, height: 410)
      bindViewModel()
   }
   
   func setNetworkSetting() {
      do {
         try reachability?.startNotifier()
      } catch {
         print(error.localizedDescription)
      }
      
      reachability?.whenReachable = { _ in
         if let favArr = try? DefaultData.shared.favoriteSubject.value() {
            self.noneFavoriteView.isHidden = favArr.isEmpty
            DefaultData.shared.favoriteSubject.onNext(favArr)
         }
      }
      
      reachability?.whenUnreachable = { _ in
         self.noneFavoriteView.isHidden = false
      }
   }
   
   func bindViewModel() {
      DefaultData.shared.favoriteSubject
         .map { !$0.isEmpty }
         .bind(to: noneFavoriteView.rx.isHidden)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.favoriteSubject
         .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.identifier,
                                           cellType: FavoriteCollectionViewCell.self)) { index, id, cell in
                                             cell.layer.cornerRadius = 35
                                             
                                             cell.initialSetting(id: id)
      }
      .disposed(by: rx.disposeBag)
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
