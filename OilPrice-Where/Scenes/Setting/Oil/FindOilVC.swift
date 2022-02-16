//
//  FindOilVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class FindOilVC: CommonViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindOilTypeViewModel!
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        OilTypeTableViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    func bindViewModel() {
        viewModel.oilSubject
            .bind(to: tableView.rx.items(cellIdentifier: OilTypeTableViewCell.id,
                                         cellType: OilTypeTableViewCell.self)) { index, type, cell in
                cell.fetch(oil: type)
                
                let displayOilType = Preferences.oil(name: type)
                let currentOilType = DefaultData.shared.oilSubject.value
                
                guard currentOilType == displayOilType else { return }
                
                self.tableView.selectRow(at: IndexPath(row: index, section: 0),
                                         animated: false,
                                         scrollPosition: .none)
            }
             .disposed(by: rx.disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Configure UI
    func makeUI() {
        navigationItem.title = "관심 유종"
        navigationController?.navigationItem.leftBarButtonItem?.tintColor = .white
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//MARK: - UITableView Delegate
extension FindOilVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let types = viewModel.oilSubject.value
        let type = Preferences.oil(name: types[indexPath.row])
        
        DefaultData.shared.oilSubject.accept(type)
    }
}
