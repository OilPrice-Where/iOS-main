//
//  SearchResultCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: SearchResultCell
final class SearchResultCell: UITableViewCell {
    //MARK: - Properties
    let titleLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    let subTitleLabel = UILabel().then {
        $0.textColor = .systemGray3
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    let distanceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Make UI
    private func makeUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(lineView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(16)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(26)
        }
        distanceLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.right.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview()
            $0.right.equalTo(distanceLabel.snp.left).offset(4)
        }
        lineView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

