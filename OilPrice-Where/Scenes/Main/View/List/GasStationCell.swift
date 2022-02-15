//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: 메인페이지의 리스트 부분에서 받아오는 주유소 목록을 나타내는 셀
final class GasStationCell: UITableViewCell {
    //MARK: - Properties
    let titleView = GasStationTitleView()
    let bottomView = GasStationBottomView()
    let lineView = UIView().then {
        $0.backgroundColor = .darkGray
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Make UI
    func makeUI() {
        contentView.layer.cornerRadius = 5
        
        addSubview(titleView)
        addSubview(lineView)
        addSubview(bottomView)
        
        titleView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(30)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.left.right.equalTo(titleView)
            $0.height.equalTo(1.2)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(8)
            $0.left.bottom.right.equalToSuperview()
        }
    }
}
