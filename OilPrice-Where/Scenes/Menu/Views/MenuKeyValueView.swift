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

    //MARK: - Properties
    private let type: MenuType
    
    let hStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .fill
        $0.distribution = .equalSpacing
    }
    
    private let logoImageView = UIImageView().then {
        $0.clipsToBounds = true
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 4
    }
    
    private let keyLabel = UILabel().then {
        $0.textAlignment = .left
    }
    
    let valueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    
    //MARK: - Initializer
    init(title: String, menuType type: MenuType) {
        self.type = type
        
        super.init(frame: .zero)
        
        makeUI(with: title)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension MenuKeyValueView {
    enum MenuType {
        case key
        case keyValue
        case image
        case subType
    }
    
    //MARK: - Set UI
    enum UIConstants {
        // MARK: - LogoImageView
        enum LogoImageView {
            static let leftOffset: CGFloat = 24
            static let size: CGFloat = 24
        }
        
        // MARK: - HStackView
        enum HStackView {
            static let leftOffsetImageType: CGFloat = 8
            static let leftOffsetOtherType: CGFloat = -24
            static let rightOffset: CGFloat = -24
        }
        
        // MARK: - KeyLabel
        enum KeyLabel {
            static let height: CGFloat = 30
        }
    }
    
    private func makeUI(with title: String) {
        configureUI()
        setConstraints()
        configureLogoImageView()
        configureKeyLabel(title: title)
    }
    
    private func configureUI() {
        addSubview(hStackView)
        addSubview(logoImageView)

        hStackView.addArrangedSubview(keyLabel)
        hStackView.addArrangedSubview(valueLabel)
    }
    
    private func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.LogoImageView.leftOffset)
            $0.centerY.equalTo(keyLabel.snp.centerY)
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
        
        hStackView.snp.makeConstraints {
            let leftOffset = (type == .image) ? UIConstants.HStackView.leftOffsetImageType : UIConstants.HStackView.leftOffsetOtherType
            $0.left.equalTo(logoImageView.snp.right).offset(leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.HStackView.rightOffset)
            $0.top.bottom.equalToSuperview()
        }
        
        keyLabel.snp.makeConstraints {
            $0.height.equalTo(UIConstants.KeyLabel.height)
        }
    }
    
    private func configureLogoImageView() {
        logoImageView.isHidden = type != .image
    }
    
    private func configureKeyLabel(title: String) {
        keyLabel.text = title
        
        switch type {
        case .key, .keyValue, .image:
            keyLabel.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        case .subType:
            keyLabel.textColor = UIColor(red: 145/255, green: 145/255, blue: 145/255, alpha: 1.0)
            keyLabel.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        }
    }
}
