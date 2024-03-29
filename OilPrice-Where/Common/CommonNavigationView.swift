//
//  CommonNavigationView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: CommonNavigationView
final class CommonNavigationView: UIView {
    //MARK: - Properties
    let backButton = UIButton().then {
        $0.setImage(Asset.Images.back.image, for: .normal)
        $0.setImage(Asset.Images.back.image, for: .highlighted)
    }
    let rightButton = UIButton()
    let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
    }
    let bottomLine = UIView().then {
        $0.backgroundColor = .systemGray5
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
    private func makeUI() {
        addSubview(backButton)
        addSubview(rightButton)
        addSubview(titleLabel)
        addSubview(bottomLine)
        
        backButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(5)
            $0.size.equalTo(44)
        }
        rightButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-2)
            $0.size.equalTo(44)
        }
        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        bottomLine.snp.makeConstraints {
            $0.left.bottom.right.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
}

