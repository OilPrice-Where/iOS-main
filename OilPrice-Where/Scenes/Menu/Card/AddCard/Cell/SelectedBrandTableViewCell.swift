//
//  SelectedBrandTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/08/14.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import CombineDataSources

final class SelectedBrandTableViewCell: UITableViewCell {
    //MARK: - Properties
    var viewModel = FindBrandViewModel()
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
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        contentView.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func bind() {
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
                            owner.isAllSwitchButton.send(isOn)
                        }
                        .store(in: &owner.viewModel.cancelBag)
                    
                    return
                }
                
                owner.isAllSwitchButton
                    .sink { isOn in
                        guard !owner.isLauchSetting else {
                            cell.brandSelectedSwitch.isOn = isOn
                            DefaultData.shared.brandsSubject.accept(isOn ? owner.viewModel.allBrands : [])
                            return
                        }
                        
                        owner.isLauchSetting = true
                    }
                    .store(in: &owner.viewModel.cancelBag)
            }))
            .store(in: &viewModel.cancelBag)
    }
}
