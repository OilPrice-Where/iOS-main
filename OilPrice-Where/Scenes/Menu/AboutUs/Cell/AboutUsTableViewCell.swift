//
//  AboutUsTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension AboutUsTableViewCell {
    // 셀 등록 객체 생성
    static let cellRegistration = UICollectionView.CellRegistration<AboutUsTableViewCell, SettingAboutUsViewModel.AboutMe> { cell, indexPath, aboutMe in
        cell.configure(
            name: aboutMe.name,
            link: aboutMe.githubLink
        )
    }
    
    // Configure Data
    private func configure(name: String?, link: String?) {
        nameLabel.text = name
        linkLabel.text = link
    }
}


//MARK: AboutUsTableViewCell
final class AboutUsTableViewCell: UICollectionViewCell {
    
    // MARK: - Properties

    private let jobTitleLabel = UILabel().then {
        $0.text = "iOS Developer"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 18)
    }
    
    private let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 17)
    }
    
    private let githubImageView = UIImageView().then {
        $0.image = Asset.Images.github.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    
    private let linkLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.light.font(size: 16)
    }
    
    
    // MARK: - Initializer
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - Set UI
private extension AboutUsTableViewCell {
    enum UIConstants {
        // Insets
        static let horizontalInset: CGFloat = 20
        static let verticalInset: CGFloat = 20
        
        // Labels
        static let jobTitleLabelHeight: CGFloat = 20
        static let nameLabelHeight: CGFloat = 20
        static let linkLabelHeight: CGFloat = 20
        
        // Spacing
        static let interLabelSpacing: CGFloat = 8
        static let githubImageLeftSpacing: CGFloat = 20
        static let linkLabelLeftSpacing: CGFloat = 3
        
        // Github Image Size
        static let githubImageSize: CGFloat = 22.5
    }
    
    func makeUI() {
        configureUI()
        setupConstraints()
    }
    
    func configureUI() {
        contentView.addSubview(jobTitleLabel)
        contentView.addSubview(nameLabel)
        contentView.addSubview(githubImageView)
        contentView.addSubview(linkLabel)
    }
    
    func setupConstraints() {
        jobTitleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIConstants.verticalInset)
            make.left.equalToSuperview().inset(UIConstants.horizontalInset)
            make.right.equalToSuperview().inset(UIConstants.horizontalInset)
            make.height.equalTo(UIConstants.jobTitleLabelHeight)
        }
        
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(jobTitleLabel.snp.bottom).offset(UIConstants.interLabelSpacing)
            make.left.equalToSuperview().inset(UIConstants.horizontalInset)
            make.right.equalToSuperview().inset(UIConstants.horizontalInset)
            make.height.equalTo(UIConstants.nameLabelHeight)
        }
        
        githubImageView.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(UIConstants.interLabelSpacing)
            make.left.equalToSuperview().inset(UIConstants.githubImageLeftSpacing)
            make.size.equalTo(UIConstants.githubImageSize)
        }
        
        linkLabel.snp.makeConstraints { make in
            make.centerY.equalTo(githubImageView.snp.centerY)
            make.left.equalTo(githubImageView.snp.right).offset(UIConstants.linkLabelLeftSpacing)
            make.right.equalToSuperview().inset(UIConstants.horizontalInset)
            make.height.equalTo(UIConstants.linkLabelHeight)
        }
    }
}
