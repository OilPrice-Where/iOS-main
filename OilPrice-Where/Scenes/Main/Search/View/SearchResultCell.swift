//
//  SearchResultCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


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
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - UI Setup
private extension SearchResultCell {
    enum UIConstants {
        static let titleTopInset: CGFloat = 16
        static let titleHeight: CGFloat = 26
        
        static let interItemSpacing: CGFloat = 4
        
        static let lineHeight: CGFloat = 1
    }
    
    func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(lineView)
    }
    
    func setupConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIConstants.titleTopInset)
            make.left.right.equalToSuperview()
            make.height.equalTo(UIConstants.titleHeight)
        }
        
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.interItemSpacing)
            make.right.equalToSuperview()
        }
        
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.interItemSpacing)
            make.left.equalToSuperview()
            make.right.equalTo(distanceLabel.snp.left).offset(-UIConstants.interItemSpacing)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIConstants.lineHeight)
        }
    }
}
