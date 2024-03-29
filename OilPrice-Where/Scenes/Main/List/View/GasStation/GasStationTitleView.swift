//
//  GasStationTitleView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit

//MARK: GasStationCell의 Title 정보
final class GasStationTitleView: UIStackView {
    // Properties
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let stationNameLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
        $0.textAlignment = .left
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set UI
    private func makeUI() {
        axis = .horizontal
        spacing = 8.0
        alignment = .fill
        distribution = .fill
        
        addArrangedSubview(logoImageView)
        addArrangedSubview(stationNameLabel)
        
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(30)
        }
    }
    
    // Configure title
    func configure(title info: GasStation) {
        logoImageView.image = Preferences.logoImage(logoName: info.brand)
        stationNameLabel.text = info.name
    }
    
    func configure(staion info: Station) {
        logoImageView.image = Preferences.logoImage(logoName: info.brand)
        stationNameLabel.text = info.name
    }
}
