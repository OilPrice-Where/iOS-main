//
//  MainListNoneView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class MainListNoneView: UIView {
    //MARK: - Properties
    let noneListImageView = UIImageView().then {
        $0.image = Asset.Images.noneListImage.image
        $0.contentMode = .scaleAspectFit
    }
    let noneListLabel = UILabel().then {
        $0.text = "근처 주유소를 찾을 수 없습니다"
        $0.textAlignment = .center
        $0.textColor = .darkGray
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        addSubview(noneListImageView)
        addSubview(noneListLabel)
        
        noneListImageView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.width.equalTo(140)
            $0.height.equalTo(130)
        }
        
        noneListLabel.snp.makeConstraints {
            $0.top.equalTo(noneListImageView.snp.bottom).offset(15)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(20)
        }
    }
}