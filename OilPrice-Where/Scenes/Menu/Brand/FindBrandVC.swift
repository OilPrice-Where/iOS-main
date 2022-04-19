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
//MARK: 탐색 브랜드 VC
final class FindBrandVC: UIViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindBrandViewModel!
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
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    //MARK: - Rx Binding ..
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
                            DefaultData.shared.brandsSubject.accept($0 ? self.viewModel.allBrands : [])
                            return
                        }
                        
                        self.isLauchSetting = true
                    })
                    .disposed(by: self.rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
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