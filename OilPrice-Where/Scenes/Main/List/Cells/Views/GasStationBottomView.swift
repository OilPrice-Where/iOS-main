//
//  GasStationBottomView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension GasStationBottomView {
    func configure(with station: GasStationSummary) {
        priceView.configure(price: station)
        
        expandView.configure(
            distance: String(format: "%.1fkm", station.distance / 1000)
        )
    }
}


//MARK: GasStationCell의 BottomView
final class GasStationBottomView: UIStackView {
    //MARK: - Properties
    let priceView = GasStationPriceView()
    let expandView = GasStationExpandView()
    
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
private extension GasStationBottomView {
    enum UIConstants {
        enum StackView {
            static let spacing: CGFloat = 5.0
        }
    }
    
    func makeUI() {
        configureUI()
    }
    
    func configureUI() {
        axis = .vertical
        spacing = UIConstants.StackView.spacing
        alignment = .fill
        distribution = .fill
        
        addArrangedSubview(priceView)
        addArrangedSubview(expandView)
    }
}
