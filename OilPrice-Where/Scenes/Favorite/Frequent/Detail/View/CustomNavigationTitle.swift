//
//  CustomNavigationTitle.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/07/17.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: CustomNavigationTitle
final class CustomNavigationTitle: UIView {
    //MARK: - Properties
    let titleLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 15)
        $0.textColor = .white
    }
    let logoImageView = UIImageView().then {
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
    
    //MARK: - Make UI
    func makeUI() {
        addSubview(titleLabel)
        addSubview(logoImageView)
        
        logoImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(25)
        }
        titleLabel.snp.makeConstraints {
            $0.left.equalTo(logoImageView.snp.right).offset(4)
            $0.centerY.right.equalToSuperview()
        }
    }
}
