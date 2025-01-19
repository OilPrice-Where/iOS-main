//
//  GasStationDirectionView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension GasStationDirectionView {
    // Configure
    func configure(image: UIImage? = nil,
                   distance: String? = nil,
                   message: String? = nil) {
        logoImageView.image = image
        
        if let distance {
            titleLabel.text = "\(distance) 안내 시작"
        } else if let message {
            titleLabel.text = message
        }
    }
}


//MARK: GasStationCell의 경로보기 버튼
final class GasStationDirectionView: UIView {
    // Properties
    private let logoImageView = UIImageView().then {
        $0.image = UIConstants.LogoImageView.image
        $0.tintColor = .white
    }
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = UIConstants.TitleLabel.font
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension GasStationDirectionView {
    enum UIConstants {
        enum TitleLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 18)

            static let centerXOffset: CGFloat = 14.5
        }
        
        enum LogoImageView {
            static let image: UIImage = Asset.Images.findMapIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let centerYOffset: CGFloat = -1
            static let rightOffset: CGFloat = -7
            static let size: CGFloat = 22
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = Asset.Colors.mainColor.color
        
        layer.borderWidth = 1.0
        layer.borderColor = Asset.Colors.mainColor.color.cgColor
        layer.cornerRadius = 5
        
        addSubview(logoImageView)
        addSubview(titleLabel)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview().offset(UIConstants.TitleLabel.centerXOffset)
            $0.centerY.equalToSuperview()
        }
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(UIConstants.LogoImageView.centerYOffset)
            $0.right.equalTo(titleLabel.snp.left).offset(UIConstants.LogoImageView.rightOffset)
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
    }
}
