//
//  KeyValueView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/09.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: KeyValueView
final class KeyValueView: UIView {
    //MARK: - Properties
    let keyLabel = UILabel().then {
        $0.font = UIConstants.KeyLabel.font
        $0.textColor = .white
        $0.textAlignment = .left
    }
    let valueLabel = UILabel().then {
        $0.font = UIConstants.ValueLabel.font
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
}


//MARK: - Set UI
private extension KeyValueView {
    enum UIConstants {
        enum KeyLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 12)
            
            static let leftOffset: CGFloat = 6
        }
        
        enum ValueLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 12)
            
            static let rightOffset: CGFloat = -6
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(keyLabel)
        addSubview(valueLabel)
    }
    
    func setConstraints() {
        keyLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.KeyLabel.leftOffset)
            $0.centerY.equalToSuperview()
        }
        valueLabel.snp.makeConstraints {
            $0.right.equalToSuperview().offset(UIConstants.ValueLabel.rightOffset)
            $0.centerY.equalToSuperview()
        }
    }
}
