//
//  CustomNavigationTitleView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/07/17.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension CustomNavigationTitleView {
    func configure(with stationDetail: GasStationDetail) {
        titleLabel.text = stationDetail.name
        logoImageView.image = stationDetail.brand.image
    }
}


final class CustomNavigationTitleView: UIView {
    //MARK: - Properties
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = UIConstants.TitleLabel.font
    }
    
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension CustomNavigationTitleView {
    enum UIConstants {
        enum LogoImageView {
            static let size: CGFloat = 25
        }
        
        enum TitleLabel {
            static let font = FontFamily.NanumSquareRound.bold.font(size: 15)
            
            static let leftOffset: CGFloat = 4
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(titleLabel)
        addSubview(logoImageView)
    }
    
    func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(logoImageView.snp.right).offset(UIConstants.TitleLabel.leftOffset)
            $0.centerY.right.equalToSuperview()
        }
    }
}
