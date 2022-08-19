//
//  SelectedBrandTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/08/14.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import RxSwift

final class SelectedBrandTableViewCell: UITableViewCell {
    //MARK: - Properties
    let bag = DisposeBag()
    var viewModel = FindBrandViewModel()
    private var isAllSwitchButton = PublishSubject<Bool>()
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
        rxBind()
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
    
    func rxBind() {
        viewModel.brandSubject
            .bind(to: tableView.rx.items(cellIdentifier: BrandTypeTableViewCell.id,
                                         cellType: BrandTypeTableViewCell.self)) { index, brand, cell in
                cell.fetchData(brand: brand)
                guard brand != "전체" else {
                    cell.brandSelectedSwitch
                        .rx
                        .isOn
                        .subscribe(onNext: {
                            self.isAllSwitchButton.onNext($0)
                        })
                        .disposed(by: self.rx.disposeBag)
                    
                    return
                }
                
                self.isAllSwitchButton
                    .subscribe(onNext: {
                        guard !self.isLauchSetting else {
                            cell.brandSelectedSwitch.isOn = $0
                            DefaultData.shared.brandsSubject.accept($0 ? self.viewModel.allBrands : [])
                            return
                        }
                        
                        self.isLauchSetting = true
                    })
                    .disposed(by: self.rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
    }
}
