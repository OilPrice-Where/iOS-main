//
//  KVVStackView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class KVVStackView: UIStackView {
    let keyLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 10)
    }
    
    let valueImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureUI() {
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
