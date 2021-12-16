//
//  AboutUsTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Then


class AboutUsTableViewCell: UITableViewCell {
    //MARK: - Properties
    let jobTitleLabel = UILabel().then {
        $0.text = "iOS Developer"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 18)
    }
    let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 17)
    }
    let githubImageView = UIImageView().then {
        $0.image = Asset.Images.github.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    let linkLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.light.font(size: 16)
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func configureUI() {
        contentView.addSubview(jobTitleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(githubImageView)
        contentView.addSubview(linkLabel)
        
        jobTitleLabel.snp.makeConstraints {
            $0.left.right.top.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(jobTitleLabel.snp.bottom).offset(8)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
        
        githubImageView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(20)
            $0.size.equalTo(22.5)
        }
        
        linkLabel.snp.makeConstraints {
            $0.centerY.equalTo(githubImageView.snp.centerY)
            $0.left.equalTo(githubImageView.snp.right).offset(3)
            $0.right.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
    }
}
