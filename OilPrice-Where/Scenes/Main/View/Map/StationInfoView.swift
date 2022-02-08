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
        $0.image = Asset.Images.logoSKGas.image //TODO: 삭제 예정
    }
    let distanceLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
    }
    let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 22)
        $0.text = "현대오일뱅크(주)직영 방배현대주유소" //TODO: 삭제 예정
    }
    let favoriteButton = UIButton().then {
        $0.imageView?.contentMode = .scaleAspectFill
        $0.setImage(Asset.Images.favoriteOffIcon.image, for: .normal)
        $0.setImage(Asset.Images.favoriteOffIcon.image, for: .highlighted)
    }
    let guideView = StationInfoGuideView()
    let priceStackView = StationInfoPriceView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        backgroundColor = .white
        
        addSubview(distanceLabel)
        addSubview(logoImageView)
        addSubview(nameLabel)
        addSubview(priceStackView)
        addSubview(guideView)
        
        guideView.snp.makeConstraints {
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(80)
        }
        priceStackView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-14)
            $0.bottom.equalTo(guideView.snp.top)
        }
        nameLabel.snp.makeConstraints {
            $0.left.equalTo(logoImageView.snp.right).offset(4)
            $0.right.equalToSuperview().offset(-14)
            $0.bottom.equalTo(priceStackView.snp.top).offset(-14)
        }
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.left.equalToSuperview().offset(14)
            $0.size.equalTo(24)
        }
    }
    
    func configure(_ station: GasStation) {
        guard let oilType = try? DefaultData.shared.oilSubject.value() else { return }
        
        logoImageView.image = Preferences.logoImage(logoName: station.brand)
        nameLabel.text = station.name
        priceStackView.priceLabel.text = Preferences.priceToWon(price: station.price)
        priceStackView.oilTypeLabel.text = Preferences.oil(code: oilType)
        
        let distance = station.distance < 1000 ? "\(Int(station.distance))m" : String(format: "%.1fkm", station.distance / 1000)
        guideView.directionLabel.text = distance + " 안내시작"
    }
}
