//
//  NoneFavoriteView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class NoneFavoriteView: UIView {
    //MARK: - Properties
    let emptyImageView = UIImageView().then {
        $0.image = Asset.Images.nonePageImage.image
        $0.contentMode = .scaleAspectFit
    }
    
    let emptyLabel = UILabel().then {
        $0.text = "즐겨 찾는 주유소가 없습니다."
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        addSubview(emptyImageView)
        addSubview(emptyLabel)
        
        emptyImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(23)
        }
    }
}
