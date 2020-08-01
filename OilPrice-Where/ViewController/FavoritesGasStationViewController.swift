//
//  FavoritesGasStationViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import TMapSDK
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation
import CenteredCollectionView

class FavoritesGasStationViewController: CommonViewController {
   var viewModel = FavoriteViewModel()
   var notiObject: NSObjectProtocol?
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
      notiObject = nil
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
      
      notiObject = NotificationCenter.default.addObserver(forName: NSNotification.Name("navigationClickEvent"),
                                                          object: nil,
                                                          queue: .main) { self.naviClickEvenet(noti: $0) }
      
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
                                             let viewModel = FavoriteCellViewModel(id: id)
                                             cell.viewModel = viewModel
                                             cell.bindViewModel()
      }
      .disposed(by: rx.disposeBag)
   }
   
   func naviClickEvenet(noti: Notification) {
      guard let userInfo = noti.userInfo,
         let katecX = userInfo["katecX"] as? Double,
         let katecY = userInfo["katecY"] as? Double,
         let stationName = userInfo["stationName"] as? String,
         let navi = userInfo["naviType"] as? String else { return }
      print(katecX, katecY)
      let coordinator = Converter.convertKatecToWGS(katec: KatecPoint(x: katecX, y: katecY))
      
      switch navi {
      case "tmap":
         if TMapApi.isTmapApplicationInstalled() {
            let _ = TMapApi.invokeRoute(stationName, coordinate: coordinator)
         } else {
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { (_) in
                                          guard let url = URL(string: TMapApi.getTMapDownUrl()) else {
                                             return
                                          }
                                          
                                          if UIApplication.shared.canOpenURL(url) {
                                             UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                          }
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
         }
      default:
         let destination = KNVLocation(name: stationName,
                                       x: NSNumber(value: katecX),
                                       y: NSNumber(value: katecY))
         let options = KNVOptions()
         options.routeInfo = false
         let params = KNVParams(destination: destination,
                                options: options)
         KNVNaviLauncher.shared().navigate(with: params) { (error) in
            self.handleError(error: error)
         }
      }
   }
   
   // 길안내 에러 발생
   func handleError(error: Error?) {
      if let error = error as NSError? {
         print(error)
         let alert = UIAlertController(title: self.title!,
                                       message: error.localizedFailureReason,
                                       preferredStyle: UIAlertControllerStyle.alert)
         alert.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.cancel,
                                       handler: nil))
         self.present(alert, animated: true, completion: nil)
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
