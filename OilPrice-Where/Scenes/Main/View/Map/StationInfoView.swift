//
//  StationInfoView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/24.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit

final class StationInfoView: UIView {
    
    enum State {
        case appear
        case disappear
    }
    
    var state: State = .disappear
    let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let distanceLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    let oilTypeLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    let priceLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}
