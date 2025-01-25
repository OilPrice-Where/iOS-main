//
//  GasStationTitleView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: - Configure
extension GasStationTitleView {
    func configure(title info: any StationRepresentable) {
        logoImageView.image = info.brand.image
        stationNameLabel.text = info.name
    }
}


//MARK: GasStationCell의 Title 정보
final class GasStationTitleView: UIStackView {
    //MARK: - Properties
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let stationNameLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
        $0.textAlignment = .left
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Set UI
private extension GasStationTitleView {
    enum UIConstants {
        enum StackView {
            static let spacing: CGFloat = 8
        }
        
        enum LogoImageView {
            static let size: CGFloat = 30
        }
        
        enum StationNameLabel {
            static let font = FontFamily.NanumSquareRound.bold.font(size: 20)
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        axis = .horizontal
        spacing = UIConstants.StackView.spacing
        alignment = .fill
        distribution = .fill
        
        addArrangedSubview(logoImageView)
        addArrangedSubview(stationNameLabel)
    }
    
    func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
    }
}
