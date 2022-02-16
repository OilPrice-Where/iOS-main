//
//  SettingVC.swift
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
final class SettingVC: UIViewController {
    //MARK: Properties
    lazy var settingTableView = UITableView(frame: .zero, style: .grouped).then {
        $0.dataSource = self
        $0.delegate = self
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        SettingTableViewCell.register($0)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingTableView.reloadData()
    }
    
    
    
    //MARK: Configure UI
    func makeUI() {
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
        
        navigationItem.title = "설정"
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(settingTableView)
        
        settingTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: Functions..
    // 이전 설정을 데이터를 불러와서
    // oilTypeLabel, findLabel 업데이트
    func fetchNavigationTitle() -> String? {
        return Preferences.navigationType(name: DefaultData.shared.naviSubject.value)
    }
    
    func fetchOilTypeString() -> String? {
        return Preferences.oil(code: DefaultData.shared.oilSubject.value)
    }
    
    func fetchDistanceString() -> String? {
        return String(DefaultData.shared.radiusSubject.value / 1000) + "KM"
    }
}

extension SettingVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        default:
            return 3
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withType: SettingTableViewCell.self, for: indexPath)
        
        cell.accessoryType = .disclosureIndicator
        
        switch SelectCellType.indexPath(at: indexPath) {
        case .selectNaviVC:
            cell.titleLabel.text = "내비게이션"
            cell.subTitleLabel.text = fetchNavigationTitle()
        case .selectOilVC:
            cell.titleLabel.text = "유종"
            cell.subTitleLabel.text = fetchOilTypeString()
        case .selectDistanceVC:
            cell.titleLabel.text = "검색 반경"
            cell.subTitleLabel.text = fetchDistanceString()
        case .selectStationVC:
            cell.titleLabel.text = "검색 브랜드"
        case .selectSalePriceVC:
            cell.titleLabel.text = "카드 할인"
        case .settingAboutUsVC:
            cell.titleLabel.text = "About us"
        case .review:
            cell.titleLabel.text = "App 평가하기"
        case .none:
            cell.accessoryType = .none
            cell.titleLabel.text = "버전"
            cell.subTitleLabel.text = "최신버전"
        }
        
        return cell
    }
}

extension SettingVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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
