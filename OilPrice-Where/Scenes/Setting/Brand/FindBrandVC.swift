//
//  FindBrandVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FindBrandVC: CommonViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindBrandViewModel!
    var isAllSwitchButton = PublishSubject<Bool>()
    var isLauchSetting = false
    
    lazy var tableView = UITableView().then {
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
        
        configureUI()
    }
    
    //MARK: - View Binding..
    func bindViewModel() {
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
                            DefaultData.shared.brandsSubject.onNext($0 ? self.viewModel.allBrands : [])
                            return
                        }
                        
                        self.isLauchSetting = true
                    })
                    .disposed(by: self.rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Configure UI
    func configureUI() {
        navigationItem.title = "검색 브랜드"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
