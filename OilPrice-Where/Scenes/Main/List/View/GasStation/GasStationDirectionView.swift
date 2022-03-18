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
    // Properties
    private let logoImageView = UIImageView().then {
        let image = Asset.Images.findMapIcon.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .white
    }
    private let titleLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 18)
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    // Set UI
    private func makeUI() {
        backgroundColor = Asset.Colors.mainColor.color
        
        layer.borderWidth = 1.0
        layer.borderColor = Asset.Colors.mainColor.color.cgColor
        layer.cornerRadius = 5
        
        addSubview(logoImageView)
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview().offset(14.5)
        }
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(22)
            $0.centerY.equalToSuperview().offset(-1)
            $0.right.equalTo(titleLabel.snp.left).offset(-7)
        }
    }
    
    // Configure distance
    func configure(distance: String) {
        titleLabel.text = "\(distance) 안내 시작"
    }
}
