//
//  StationInfoPriceView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/07.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: StationInfoView 내부 가격 및 유종 표시
final class StationInfoPriceView: UIStackView {
    //MARK: - Properties
    let hStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .fill
        $0.spacing = 6
    }
    let oilTypeLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.text = "고급유" //TODO: 삭제 예정
    }
    let priceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 32)
        $0.text = "8,888" //TODO: 삭제 예정
    }
    let lineView = UIView().then {
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
    
    //MARK: - Make UI
    func makeUI() {
        axis = .vertical
        alignment = .trailing
        distribution = .fill
        
        addArrangedSubview(hStackView)
        
        hStackView.addArrangedSubview(oilTypeLabel)
        hStackView.addArrangedSubview(priceLabel)
        
        lineView.snp.makeConstraints {
            $0.width.equalTo(1)
        }
    }
}
