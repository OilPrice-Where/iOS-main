//
//  MenuKeyValueView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: MenuKeyValueView
final class MenuKeyValueView: UIView {
    enum MenuType {
        case key
        case keyValue
        case subType
    }
    //MARK: - Properties
    let type: MenuType
    let hStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    lazy var keyLabel = UILabel().then {
        $0.textAlignment = .left
        switch type {
        case .key, .keyValue:
            $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        case .subType:
            $0.textColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
            $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        }
    }
    let valueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    
    //MARK: - Initializer
    init(type: MenuType) {
        self.type = type
        super.init(frame: .zero)
        
        makeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Make UI
    func makeUI() {
        addSubview(hStackView)
        
        hStackView.addArrangedSubview(keyLabel)
        hStackView.addArrangedSubview(valueLabel)
        
        hStackView.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(24)
            $0.top.bottom.equalToSuperview()
        }
        
        keyLabel.snp.makeConstraints {
            $0.height.equalTo(30)
        }
    }
}
