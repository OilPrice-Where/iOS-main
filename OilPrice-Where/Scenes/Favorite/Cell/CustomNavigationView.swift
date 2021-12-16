//
//  CustomNavigationView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class CustomNavigationView: UIView {
    //MARK: - Properties
    let logoImageView = UIImageView().then {
        $0.image = Asset.Images.navigationIcon.image
        $0.contentMode = .scaleAspectFit
        $0.backgroundColor = .white
    }
    
    let titleLabel = UILabel().then {
        $0.text = "길찾기"
        $0.textColor = Asset.Colors.mainColor.color
        $0.textAlignment = .left
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
        layer.cornerRadius = 6
        layer.borderColor = Asset.Colors.mainColor.color.cgColor
        layer.borderWidth = 1.5
        
        addSubview(logoImageView)
        addSubview(titleLabel)
        
        logoImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-25.5)
            $0.size.equalTo(22)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(logoImageView.snp.right).offset(7)
            $0.right.equalToSuperview()
        }
    }
}
