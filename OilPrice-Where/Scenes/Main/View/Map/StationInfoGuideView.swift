//
//  StationInfoGuideView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/07.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: StationInfo의 길 안내 & 즐겨찾기
final class StationInfoGuideView: UIView {
    //MARK: - Properties
    let favoriteButton = UIButton().then {
        let image = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.setImage(image, for: .highlighted)
        $0.layer.borderWidth = 1.5
        $0.layer.borderColor = Asset.Colors.mainColor.color.cgColor
        $0.layer.cornerRadius = 5.0
        $0.imageView?.tintColor = Asset.Colors.mainColor.color
        
    }
    let directionView = UIView().then {
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = 5.0
    }
    let directionImageView = UIImageView().then {
        let image = Asset.Images.navigationIcon.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .white
        $0.image = image
    }
    let directionLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
        $0.textColor = .white
        $0.text = "88.88km 안내 시작"
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
        addSubview(favoriteButton)
        addSubview(directionView)
//        directionView.addSubview(directionImageView)
        directionView.addSubview(directionLabel)
        
        favoriteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(14)
            $0.width.equalTo(60)
            $0.height.equalTo(50)
        }
        directionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalTo(favoriteButton.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(50)
        }
        directionLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}
