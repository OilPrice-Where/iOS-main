//
//  KeyValueView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/09.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: KeyValueView
final class KeyValueView: UIView {
    //MARK: - Properties
    let keyLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        $0.textColor = .white
        $0.textAlignment = .left
    }
    let valueLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        $0.textColor = .white
        $0.textAlignment = .right
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        addSubview(keyLabel)
        addSubview(valueLabel)
        
        keyLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(6)
            $0.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-6)
            $0.centerY.equalToSuperview()
        }
    }
}
