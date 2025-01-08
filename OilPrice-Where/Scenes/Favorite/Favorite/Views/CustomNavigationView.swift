//
//  CustomNavigationView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import SnapKit
import Then


//MARK: 길찾기 버튼
final class CustomNavigationView: UIView {
    //MARK: - Properties
    let logoImageView = UIImageView().then {
        $0.image = UIConstants.LogoImageView.image
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
    }
    let titleLabel = UILabel().then {
        $0.text = UIConstants.TitleLabel.text
        $0.textColor = UIConstants.TitleLabel.textColor
        $0.textAlignment = .left
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Set UI
private extension CustomNavigationView {
    enum UIConstants {
        enum ContentView {
            static let cornerRadius: CGFloat = 6
            static let borderWidth: CGFloat = 1.5
            
            static let borderColor: CGColor = Asset.Colors.mainColor.color.cgColor
        }
        
        enum LogoImageView {
            static let image: UIImage = Asset.Images.navigationIcon.image
            
            static let centerXOffset: CGFloat = -25.5
            static let size: CGFloat = 22
        }
        
        enum TitleLabel {
            static let text: String = "길찾기"
            static let textColor: UIColor = Asset.Colors.mainColor.color
            
            static let centerXOffset: CGFloat = -25.5
            static let size: CGFloat = 22
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        layer.cornerRadius = UIConstants.ContentView.cornerRadius
        layer.borderColor = UIConstants.ContentView.borderColor
        layer.borderWidth = UIConstants.ContentView.borderWidth
        
        addSubview(logoImageView)
        addSubview(titleLabel)
    }
    
    func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(UIConstants.LogoImageView.centerXOffset)
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(logoImageView.snp.right).offset(7)
            $0.right.equalToSuperview()
        }
    }
}
