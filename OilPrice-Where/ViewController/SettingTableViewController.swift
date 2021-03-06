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

enum SelectCellType {
   case selectMapVC
   case selectNaviVC
   case selectOilVC
   case selectDistanceVC
   case selectStationVC
   case selectSalePriceVC
   case settingAboutUsVC
   case review
   case none
}

extension SelectCellType {
   static func indexPath(at indexPath: IndexPath) -> SelectCellType {
      switch (indexPath.section, indexPath.row) {
      case (0, 0):
         return .selectMapVC
      case (0, 1):
         return .selectNaviVC
      case (1, 0):
         return .selectOilVC
      case (1, 1):
         return .selectDistanceVC
      case (1, 2):
         return .selectStationVC
      case (1, 3):
         return .selectSalePriceVC
      case (2, 0):
         return .settingAboutUsVC
      case (2, 1):
         return review
      default:
         return .none
      }
   }
}

// 주유소 탐색 설정 페이지
// 사용자 유종과 탐색 반경을 변경하면 메인페이지에 업데이트 되어 적용 된다.
// 설정 저장 방식은 피리스트('UserInfo'에 저장)
// ** 탐색반경 : 3KM, 유종 : nil **
class SettingTableViewController: UITableViewController {
   @IBOutlet private weak var oilTypeLabel : UILabel! // 현재 탐색 하고 있는 오일의 타입
   @IBOutlet private weak var findLabel : UILabel! // 현재 탐색 하고 있는 탐색 반경
   @IBOutlet private weak var findNaviType: UILabel!
   @IBOutlet private weak var selectMapType: UILabel!
   
   override var preferredStatusBarStyle: UIStatusBarStyle {
      return .lightContent
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      bindViewModel()
   }
   
   // 이전 설정을 데이터를 불러와서
   // oilTypeLabel, findLabel 업데이트
   func bindViewModel() {
      DefaultData.shared.mapsSubject
         .map { Preferences.mapsType(code: $0) }
         .bind(to: selectMapType.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.naviSubject
         .map { Preferences.navigationType(name: $0) }
         .bind(to: findNaviType.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.oilSubject
         .map { Preferences.oil(code: $0) }
         .bind(to: oilTypeLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      DefaultData.shared.radiusSubject
         .map { String($0 / 1000) + "KM" }
         .bind(to: findLabel.rx.text)
         .disposed(by: rx.disposeBag)
   }
}

extension SettingTableViewController {
   override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let storyboard = UIStoryboard(name: "Main", bundle: nil)
      
      switch SelectCellType.indexPath(at: indexPath) {
      case .selectMapVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SelectMapsViewController.identifier) as? SelectMapsViewController {
            let viewModel = SelectMapsViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .selectNaviVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SelectNavigationController.identifier) as? SelectNavigationController {
            let viewModel = SelectNaviViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .selectOilVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SelectOilViewController.identifier) as? SelectOilViewController {
            let viewModel = SelectOilTypeViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .selectDistanceVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SelectDistanceViewController.identifier) as? SelectDistanceViewController {
            let viewModel = SelectDistanceViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .selectStationVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SelectStationViewController.identifier) as? SelectStationViewController {
            let viewModel = SelectStationViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .selectSalePriceVC:
         if var vc = storyboard.instantiateViewController(withIdentifier: SettingEditSalePriceViewController.identifier) as? SettingEditSalePriceViewController {
            let viewModel = EditSalePriceViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
         }
      case .settingAboutUsVC:
         if let vc = storyboard.instantiateViewController(withIdentifier: SettingAboutUsViewController.identifier) as? SettingAboutUsViewController {
            navigationController?.pushViewController(vc, animated: true)
         }
      case .review:
         let id = "1435350344"
         if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
            // 유효한 URL인지 검사
            if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
               UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            } else {
               UIApplication.shared.openURL(reviewURL)
            }
         }
      case .none:
         break
      }
   }
}
