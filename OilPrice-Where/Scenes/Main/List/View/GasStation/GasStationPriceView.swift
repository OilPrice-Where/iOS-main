//
//  GasStationPriceView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit

//MARK: GasStationCell의 Price 정보
final class GasStationPriceView: UIView {
    //MARK: - Properties
    private let typeLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
        $0.textColor = .lightGray
        $0.textAlignment = .right
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let priceLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 33)
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
    
    //MARK: - Make UI
    private func makeUI() {
        addSubview(typeLabel)
        addSubview(priceLabel)
        
        priceLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(47)
            $0.centerY.equalToSuperview()
        }
        typeLabel.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.right.equalTo(priceLabel.snp.left).offset(-5)
            $0.centerY.equalToSuperview().offset(4)
        }
    }
    
    func configure(price info: GasStation) {
        typeLabel.text = Preferences.oil(code: DefaultData.shared.oilSubject.value)
        priceLabel.text = Preferences.priceToWon(price: info.price)
    }
}
