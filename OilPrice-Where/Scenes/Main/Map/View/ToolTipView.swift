//
//  ToolTipView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/09.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: 전체 평균 가격
final class ToolTipView: UIView {
    //MARK: - Properties
    let contentVStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.distribution = .fillEqually
        $0.spacing = 0
    }
    let lowPriceView = KeyValueView().then {
        $0.keyLabel.text = "최저:"
        $0.valueLabel.text = "0원"
        $0.backgroundColor = UIColor(red: 100/255, green: 180/255, blue: 255/255, alpha: 1.0)
    }
    let avgPriceView = KeyValueView().then {
        $0.keyLabel.text = "평균:"
        $0.valueLabel.text = "0원"
    }
    let findView = KeyValueView().then {
        $0.keyLabel.text = "반경:"
    }
    let stationCountView = KeyValueView().then {
        $0.keyLabel.text = "주유소:"
        $0.valueLabel.text = "0개"
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
        backgroundColor = Asset.Colors.mainColor.color
        layer.cornerRadius = 5
        layer.masksToBounds = true
        
        addSubview(contentVStackView)
        contentVStackView.addArrangedSubview(lowPriceView)
        contentVStackView.addArrangedSubview(avgPriceView)
        contentVStackView.addArrangedSubview(findView)
        contentVStackView.addArrangedSubview(stationCountView)
        
        contentVStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(stations: [GasStation]) {
        let radius = DefaultData.shared.radiusSubject.value
        let avg = stations.reduce(0) { $0 + $1.price }

        lowPriceView.valueLabel.text = Preferences.priceToWon(price: stations.first?.price ?? 0) + "원"
        avgPriceView.valueLabel.text = Preferences.priceToWon(price: avg / stations.count) + "원"
        findView.valueLabel.text = "\(radius / 1000)KM"
        stationCountView.valueLabel.text = "\(stations.count)개"
    }
}
