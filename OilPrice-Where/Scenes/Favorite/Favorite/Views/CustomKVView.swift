//
//  CustomKVView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: Key(Label)/Value(Label) View
final class CustomKVView: UIView {
    //MARK: Properties
    let keyLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = UIConstants.KeyLabel.font
    }
    let valueLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIConstants.ValueLabel.font
    }
    
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Set UI
private extension CustomKVView {
    enum UIConstants {
        enum KeyLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 15)
            
            static let rightOffset: CGFloat = -8
        }
        
        enum ValueLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 15)
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
        valueLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
        }
        keyLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
            $0.right.equalTo(valueLabel.snp.left).offset(UIConstants.KeyLabel.rightOffset)
        }
    }
}
