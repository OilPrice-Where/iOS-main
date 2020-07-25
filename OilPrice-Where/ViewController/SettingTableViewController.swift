//
//  SettingTableViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import NSObject_Rx
import RxCocoa

// 주유소 탐색 설정 페이지
// 사용자 유종과 탐색 반경을 변경하면 메인페이지에 업데이트 되어 적용 된다.
// 설정 저장 방식은 피리스트('UserInfo'에 저장)
// ** 탐색반경 : 3KM, 유종 : nil **
class SettingTableViewController: CommonViewController {
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var oilTypeLabel : UILabel! // 현재 탐색 하고 있는 오일의 타입
    @IBOutlet private weak var findLabel : UILabel! // 현재 탐색 하고 있는 탐색 반경
    @IBOutlet private weak var findBrandType : UILabel! // 현재 탐색 하고 있는 브랜드
    
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
    override func viewDidLoad() {
        super.viewDidLoad()
      
        bindViewModel()
    }
    
    // 이전 설정을 데이터를 불러와서
    // oilTypeLabel, findLabel, findBrandType 업데이트
    func bindViewModel() {
      DefaultData.shared.oilSubject
         .map { Preferences.oil(code: $0) }
         .bind(to: oilTypeLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.radiusSubject
         .map { String($0 / 1000) + "KM" }
         .bind(to: findLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.brandSubject
         .map { Preferences.brand(code: $0) }
         .bind(to: findBrandType.rx.text)
         .disposed(by: rx.disposeBag)
      
      tableView.rx.itemSelected
         .subscribe(onNext: {
            let selectIndex = ($0.section, $0.row)
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            switch selectIndex {
            case (0, 0):
               print("공지사항")
            case (1, 0):
               if let vc = storyboard.instantiateViewController(withIdentifier: SelectOilViewController.identifier) as? SelectOilViewController {
                  self.navigationController?.pushViewController(vc, animated: true)
               }
            case (1, 1):
               if let vc = storyboard.instantiateViewController(withIdentifier: SelectDistanceViewController.identifier) as? SelectDistanceViewController {
                  self.navigationController?.pushViewController(vc, animated: true)
               }
            case (1, 2):
               if let vc = storyboard.instantiateViewController(withIdentifier: SelectStationViewController.identifier) as? SelectStationViewController {
                  self.navigationController?.pushViewController(vc, animated: true)
               }
            case (2, 0):
               if let vc = storyboard.instantiateViewController(withIdentifier: AboutUsViewController.identifier) as? AboutUsViewController {
                  self.navigationController?.pushViewController(vc, animated: true)
               }
            case (2, 1):
               let id = "1435350344"
               if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
                   // 유효한 URL인지 검사
                   if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                       UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                   } else {
                       UIApplication.shared.openURL(reviewURL)
                   }
               }
            default:
               break
            }
         })
         .disposed(by: rx.disposeBag)
      
    }
}

