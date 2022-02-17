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
    let stationView = GasStationView()
    
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
        backgroundColor = .systemGroupedBackground
        contentView.addSubview(stationView)
        
        stationView.layer.cornerRadius = 5
        
        stationView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(station info: GasStation) {
        stationView.titleView.configure(title: info)
        stationView.bottomView.priceView.configure(price: info)
    }
}
