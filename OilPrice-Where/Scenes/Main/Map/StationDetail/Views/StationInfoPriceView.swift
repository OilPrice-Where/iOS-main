//
//  StationInfoPriceView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/07.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension StationInfoPriceView {
    func configure(fuelType: FuelType, price: Int) {
        priceLabel.text = price.decimalNumber
        oilTypeLabel.text = fuelType.displayName
    }
}


//MARK: StationInfoView 내부 가격 및 유종 표시
final class StationInfoPriceView: UIStackView {
    //MARK: - Properties
    private let horizontalStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = UIConstants.HorizontalStackView.spacing
    }
    private let oilTypeLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = UIConstants.OilTypeLabel.font
    }
    private let priceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIConstants.PriceLabel.font
    }
    private let lineView = UIView().then {
        $0.backgroundColor = .lightGray
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
private extension StationInfoPriceView {
    enum UIConstants {
        enum HorizontalStackView {
            static let spacing: CGFloat = 6
        }
        
        enum OilTypeLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
        }
        
        enum PriceLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 32)
        }
        
        enum LineView {
            static let width: CGFloat = 1
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        axis = .vertical
        alignment = .trailing
        distribution = .fill
        
        addArrangedSubview(horizontalStackView)
        horizontalStackView.addArrangedSubview(oilTypeLabel)
        horizontalStackView.addArrangedSubview(priceLabel)
    }
    
    func setConstraints() {
        lineView.snp.makeConstraints {
            $0.width.equalTo(UIConstants.LineView.width)
        }
    }
}
