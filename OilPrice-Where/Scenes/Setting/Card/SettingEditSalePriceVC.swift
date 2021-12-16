//
//  SettingEditSalePriceVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class SettingEditSalePriceVC: CommonViewController, ViewModelBindableType {
    //MARK: - Properties
    static let identifier = "SettingEditSalePriceVC"
    
    var viewModel: EditSalePriceViewModel!
    
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.keyboardDismissMode = .onDrag
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        SalePriceTableViewCell.register($0)
        // TapGesture
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTapAction))
        $0.addGestureRecognizer(tap)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    @objc func handleTapAction() {
        tableView.endEditing(true)
    }
    
    func bindViewModel() {
        viewModel.brandsInfoSubject
            .bind(to: tableView.rx.items(cellIdentifier: SalePriceTableViewCell.id,
                                         cellType: SalePriceTableViewCell.self)) { item, info, cell in
                cell.fetchData(brand: info)
                cell.selectionStyle = .none
            }
             .disposed(by: rx.disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    func configureUI() {
        navigationItem.title = "카드 할인"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension SettingEditSalePriceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 40))
        let label = UILabel(frame: CGRect(x: 17, y: 35, width: tableView.bounds.width - 16, height: 20))
        label.text = "소유한 카드의 리터당 할인정보 입력"
        label.font = UIFont(name: "NanumSquareRoundR", size: 13)
        label.textAlignment = .left
        label.textColor = .darkGray
        
        view.addSubview(label)
        
        return view
    }
}
