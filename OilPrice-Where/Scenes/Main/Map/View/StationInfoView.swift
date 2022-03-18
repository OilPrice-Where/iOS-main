//
//  StationInfoView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/24.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
//MARK: MapView에 주유소 정보 Content View
final class StationInfoView: UIView {
    //MARK: - Properties
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    private let favoriteButton = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setImage(Asset.Images.favoriteOffIcon.image, for: .normal)
        $0.setImage(Asset.Images.favoriteOffIcon.image, for: .highlighted)
    }
    private let priceStackView = StationInfoPriceView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        backgroundColor = .white
        
        addSubview(logoImageView)
        addSubview(nameLabel)
        addSubview(priceStackView)
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.left.equalTo(logoImageView.snp.right).offset(4)
            $0.right.equalToSuperview().offset(-14)
        }
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.left.equalToSuperview().offset(14)
            $0.size.equalTo(24)
        }
        priceStackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-14)
            $0.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
    }
    
    //MARK: - Configure station
    func configure(_ station: GasStation) {
        let oilType = DefaultData.shared.oilSubject.value
        
        logoImageView.image = Preferences.logoImage(logoName: station.brand)
        nameLabel.text = station.name
        priceStackView.priceLabel.text = Preferences.priceToWon(price: station.price)
        priceStackView.oilTypeLabel.text = Preferences.oil(code: oilType)
    }
}
