//
//  GasStationBottomView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: GasStationCell의 BottomView
final class GasStationBottomView: UIStackView {
    //MARK: - Properties
    let priceView = GasStationPriceView()
    let expandView = GasStationExpandView().then {
        $0.isHidden = true
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
        spacing = 5.0
        alignment = .fill
        distribution = .fill
        
        addArrangedSubview(priceView)
        addArrangedSubview(expandView)
        
        expandView.snp.makeConstraints {
            $0.height.equalTo(40)
        }
    }
}
