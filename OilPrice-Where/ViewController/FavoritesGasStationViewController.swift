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

class FavoritesGasStationViewController: CommonViewController {
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet weak var pager: UIPageControl! // Page Controller
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
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
   
   @IBAction func pageChanged(_ sender: UIPageControl) {
   }
}
