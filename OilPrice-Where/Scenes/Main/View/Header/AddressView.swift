//
//  AddressView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class AddressView: UIView {
    //MARK: - Properties
    let geoLogoImageView = UIImageView().then {
        $0.image = Asset.Images.geoIcon.image
        $0.contentMode = .scaleAspectFit
    }
    
    let valueLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
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
        backgroundColor = Asset.Colors.mainColor.color
        
        addSubview(geoLogoImageView)
        addSubview(valueLabel)
        
        valueLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-20)
            $0.centerX.equalToSuperview()
            $0.left.greaterThanOrEqualToSuperview().offset(25)
            $0.right.lessThanOrEqualToSuperview().offset(0)
        }
        
        geoLogoImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.centerY.equalTo(valueLabel)
            $0.right.equalTo(valueLabel.snp.left).offset(-5)
        }
    }
    
    func fetch(geoCode: String?) {
        guard let geoCode = geoCode else { return }
        valueLabel.text = geoCode
    }
}
