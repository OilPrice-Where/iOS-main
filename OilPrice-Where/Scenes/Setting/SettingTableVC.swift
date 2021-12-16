//
//  SettingTableVC.swift
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
final class SettingTableVC: UITableViewController {
    @IBOutlet private weak var oilTypeLabel : UILabel! // 현재 탐색 하고 있는 오일의 타입
    @IBOutlet private weak var findLabel : UILabel! // 현재 탐색 하고 있는 탐색 반경
    @IBOutlet private weak var findNaviType: UILabel!
    
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

extension SettingTableVC {
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch SelectCellType.indexPath(at: indexPath) {
        case .selectNaviVC:
            var vc = FindNavigationVC()
            let viewModel = FindNavigationViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        case .selectOilVC:
            var vc = FindOilVC()
            let viewModel = FindOilTypeViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        case .selectDistanceVC:
            var vc = FindDistanceVC()
            let viewModel = FindDistanceViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        case .selectStationVC:
            var vc = FindBrandVC()
            let viewModel = FindBrandViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        case .selectSalePriceVC:
            var vc = SettingEditSalePriceVC()
            let viewModel = EditSalePriceViewModel()
            vc.bind(viewModel: viewModel)
            navigationController?.pushViewController(vc, animated: true)
        case .settingAboutUsVC:
            let vc = SettingAboutUsVC()
            navigationController?.pushViewController(vc, animated: true)
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
