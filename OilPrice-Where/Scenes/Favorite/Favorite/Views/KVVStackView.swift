//
//  KVVStackView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: Key(Label)/Value(ImageView) VStack View
final class KVVStackView: UIStackView {
    //MARK: Properties
    let keyLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = UIConstants.KeyLabel.font
    }
    let valueImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
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
private extension KVVStackView {
    enum UIConstants {
        enum ContentView {
            static let spacing: CGFloat = 3
        }
        
        enum KeyLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 10)
            
            static let height: CGFloat = 30
        }
        
        enum ValueImageView {
            static let height: CGFloat = 14
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = UIConstants.ContentView.spacing
        
        addArrangedSubview(valueImageView)
        addArrangedSubview(keyLabel)
    }
    
    func setConstraints() {
        valueImageView.snp.makeConstraints {
            $0.height.equalTo(UIConstants.KeyLabel.height)
        }
        keyLabel.snp.makeConstraints {
            $0.height.equalTo(UIConstants.ValueImageView.height)
        }
    }
}
