//
//  KVVStackView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import SnapKit
import Then
//MARK: Key(Label)/Value(ImageView) VStack View
final class KVVStackView: UIStackView {
    // Properties
    let keyLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 10)
    }
    let valueImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set UI
    private func makeUI() {
        axis = .vertical
        distribution = .fill
        alignment = .fill
        spacing = 3
        
        addArrangedSubview(valueImageView)
        addArrangedSubview(keyLabel)
        
        valueImageView.snp.makeConstraints {
            $0.height.equalTo(30)
        }
        
        keyLabel.snp.makeConstraints {
            $0.height.equalTo(14)
        }
    }
}
