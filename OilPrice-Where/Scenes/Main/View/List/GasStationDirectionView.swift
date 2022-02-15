//
//  GasStationDirectionView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: GasStationCell의 경로보기 버튼
final class GasStationDirectionView: UIView {
    //MARK: - Properties
    let logoImageView = UIImageView().then {
        $0.image = Asset.Images.findMapIcon.image
    }
    let titleLabel = UILabel().then {
        $0.text = "경로 보기"
        $0.textColor = Asset.Colors.mainColor.color
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 18)
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
        layer.borderWidth = 1.0
        layer.borderColor = Asset.Colors.mainColor.color.cgColor
        layer.cornerRadius = 5
        
        addSubview(logoImageView)
        addSubview(titleLabel)
        
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(22)
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(-43)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(logoImageView.snp.right).offset(7)
            $0.right.equalToSuperview()
        }
    }
}
