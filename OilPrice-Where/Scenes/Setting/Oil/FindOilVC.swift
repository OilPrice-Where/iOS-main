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
//MARK: 찾는 유종 선택 VC
final class FindOilVC: UIViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindOilTypeViewModel!
    private lazy var tableView = UITableView().then {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Rx Binding ..
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
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "관심 유종"
        
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
