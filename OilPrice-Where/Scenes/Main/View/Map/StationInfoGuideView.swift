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
    let directionButton = UIButton().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 5.0
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 18)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.textAlignment = .center
        $0.backgroundColor = Asset.Colors.mainColor.color
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
        addSubview(directionButton)
        
        favoriteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalToSuperview().offset(14)
            $0.width.equalTo(80)
            $0.height.equalTo(38)
        }
        directionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.left.equalTo(favoriteButton.snp.right).offset(10)
            $0.right.equalToSuperview().offset(-14)
            $0.height.equalTo(38)
        }
    }
}
