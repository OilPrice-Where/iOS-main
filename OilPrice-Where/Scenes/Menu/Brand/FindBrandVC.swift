//
//  FindBrandVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CombineDataSources
//MARK: 탐색 브랜드 VC
final class FindBrandVC: UIViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindBrandViewModel!
    private var isAllSwitchButton = PassthroughSubject<Bool, Never>()
    private var isLauchSetting = false
    private lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        BrandTypeTableViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    //MARK: - Rx Binding ..
    func bindViewModel() {
        viewModel.brandSubject
            .bind(subscriber: tableView.rowsSubscriber(cellIdentifier: BrandTypeTableViewCell.id,
                                                       cellType: BrandTypeTableViewCell.self,
                                                       cellConfig: { [weak self] cell, indexPath, brand in
                guard let owner = self else { return }
                
                cell.fetchData(brand: brand)
                guard brand != "전체" else {
                    cell.brandSelectedSwitch
                        .isOnPublisher
                        .sink { isOn in
                            DefaultData.shared.brandsSubject.accept(isOn ? owner.viewModel.allBrands : [])
                            owner.isAllSwitchButton.send(isOn)
                        }
                        .store(in: &owner.viewModel.cancelBag)
                    
                    return
                }
                
                owner.isAllSwitchButton
                    .sink { isOn in
                        guard !owner.isLauchSetting else {
                            cell.brandSelectedSwitch.isOn = isOn
                            return
                        }
                        
                        owner.isLauchSetting = true
                    }
                    .store(in: &owner.viewModel.cancelBag)
            }))
            .store(in: &viewModel.cancelBag)
    }
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "검색 브랜드"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
