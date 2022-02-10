//
//  MainListView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class MainListView: UIView {
    //MARK: - Properties
    let headerView = MainListHeaderView()
    let priceSortedButton = UIButton().then {
        $0.tag = 1
        $0.setTitle("가격순", for: .normal)
        $0.setTitle("가격순", for: .highlighted)
        $0.isSelected = true
        $0.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.darkMain.color, for: .selected)
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
    }
    let distanceSortedButton = UIButton().then {
        $0.tag = 2
        $0.setTitle("거리순", for: .normal)
        $0.setTitle("거리순", for: .highlighted)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.darkMain.color, for: .selected)
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
    }
    
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        GasStationCell.register($0)
    }
    
    var noneView = MainListNoneView().then {
        $0.isHidden = false
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        backgroundColor = Asset.Colors.tableViewBackground.color
        
        addSubview(headerView)
        addSubview(priceSortedButton)
        addSubview(distanceSortedButton)
        addSubview(tableView)
        addSubview(noneView)
        
        headerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(219.5)
        }
        
        priceSortedButton.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.equalToSuperview().offset(10)
            $0.width.equalTo(45)
            $0.height.equalTo(30)
        }
        
        distanceSortedButton.snp.makeConstraints {
            $0.top.equalTo(headerView.snp.bottom)
            $0.left.equalTo(priceSortedButton.snp.right).offset(10)
            $0.width.equalTo(45)
            $0.height.equalTo(30)
        }
        
        tableView.snp.makeConstraints {
            $0.top.equalTo(priceSortedButton.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        
        noneView.snp.makeConstraints {
            $0.centerY.equalTo(tableView)
            $0.centerX.equalTo(tableView)
            $0.width.equalTo(140)
            $0.height.equalTo(165)
        }
    }
}