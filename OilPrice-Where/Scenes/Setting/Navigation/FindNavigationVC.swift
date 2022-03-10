//
//  FindNavigationVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

final class FindNavigationVC: UIViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindNavigationViewModel!
    
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        NavigaionTypeTableViewCell.register($0)
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
    
    func bindViewModel() {
        viewModel.naviSubject
            .bind(to: tableView.rx.items(cellIdentifier: NavigaionTypeTableViewCell.id,
                                         cellType: NavigaionTypeTableViewCell.self)) { index, name, cell in
                cell.fetch(navigation: name)
                
                let displayNaviType = Preferences.navigation(name: name)
                let currentNaviType = DefaultData.shared.naviSubject.value
                guard displayNaviType == currentNaviType else { return }
                
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
        navigationItem.title = "내비게이션"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//MARK: - UITableView Delegate
extension FindNavigationVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let types = viewModel.naviSubject.value
        let type = Preferences.navigation(name: types[indexPath.row])
        
        DefaultData.shared.naviSubject.accept(type)
    }
}
