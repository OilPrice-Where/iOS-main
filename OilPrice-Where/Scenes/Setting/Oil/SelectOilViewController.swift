//
//  SelectOilViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class SelectOilViewController: CommonViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: SelectOilTypeViewModel!
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        OilTypeTableViewCell.register($0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    func bindViewModel() {
        viewModel.oilSubject
            .bind(to: tableView.rx.items(cellIdentifier: OilTypeTableViewCell.id,
                                         cellType: OilTypeTableViewCell.self)) { index, type, cell in
                cell.configure(typeName: type)
            }
             .disposed(by: rx.disposeBag)
        
        tableView.rx.modelSelected(String.self)
            .subscribe(onNext: {
                let type = Preferences.oil(name: $0)
                DefaultData.shared.oilSubject.onNext(type)
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configureUI() {
        navigationItem.title = "관심 유종"
        navigationController?.navigationItem.leftBarButtonItem?.tintColor = .white
        
        
    }
}
