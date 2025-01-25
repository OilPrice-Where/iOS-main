//
//  GasStationPriceView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension GasStationPriceView {
    func configure(price info: GasStationSummary) {
        typeLabel.text = FuelType(code: DefaultData.shared.oilSubject.value).displayName
        priceLabel.text = info.price.decimalNumber
    }
}


//MARK: GasStationCell의 Price 정보
final class GasStationPriceView: UIView {
    //MARK: - Properties
    private let typeLabel = UILabel().then {
        $0.font = UIConstants.PriceLabel.font
        $0.textColor = .lightGray
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let priceLabel = UILabel().then {
        $0.font = UIConstants.TypeLabel.font
        $0.textAlignment = .right
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension GasStationPriceView {
    enum UIConstants {
        enum PriceLabel {
            static let font = FontFamily.NanumSquareRound.bold.font(size: 14)
            
            static let rightOffset: CGFloat = -16
            static let height: CGFloat = 47
        }
        
        enum TypeLabel {
            static let font = FontFamily.NanumSquareRound.extraBold.font(size: 33)
            
            static let rightOffset: CGFloat = -5
            static let centerYOffset: CGFloat = 4
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(typeLabel)
        addSubview(priceLabel)
    }
    
    func setConstraints() {
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(UIConstants.PriceLabel.rightOffset)
            $0.height.equalTo(UIConstants.PriceLabel.height)
            $0.centerY.equalToSuperview()
        }
        typeLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(priceLabel.snp.left).offset(UIConstants.TypeLabel.rightOffset)
            $0.centerY.equalToSuperview().offset(UIConstants.TypeLabel.centerYOffset)
        }
    }
}
