//
//  SettingTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/16.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit
//MARK: - Setting Cell
class SettingTableViewCell: UITableViewCell {
    // Properties
    private let titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    private let subTitleLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Override Method
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        subTitleLabel.text = nil
    }
    
    // Set UI
    private func makeUI() {
        selectionStyle = .none
        accessoryType = .disclosureIndicator
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        
        subTitleLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-10)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(80)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalTo(subTitleLabel.snp.left)
            $0.centerY.equalToSuperview()
        }
    }
    
    // Configure
    func configure(title: String?, subTitle: String? = nil) {
        titleLabel.text = title
        subTitleLabel.text = subTitle
    }
}
