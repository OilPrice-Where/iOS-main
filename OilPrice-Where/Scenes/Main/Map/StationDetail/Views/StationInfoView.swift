//
//  StationInfoView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/24.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: - Configure station
extension StationInfoView {
    func configure(fuelType: FuelType, station: GasStationSummary) {
        logoImageView.image = station.brand.image
        nameLabel.text = station.name
        priceStackView.configure(
            fuel: FuelPrice(fuelType: fuelType, price: station.price)
        )
    }
}


//MARK: MapView에 주유소 정보 Content View
final class StationInfoView: UIView {
    //MARK: - Properties
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIConstants.NameLabel.font
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
}


//MARK: - Set UI
private extension StationInfoView {
    enum UIConstants {
        enum LogoImageView {
            static let leftOffset: CGFloat = 14
            static let size: CGFloat = 24
        }
        
        enum NameLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 22)
            
            static let topOffset: CGFloat = 20
            static let leftOffset: CGFloat = 4
            static let rightOffset: CGFloat = -14
        }
        
        enum PriceStackView {
            static let topOffset: CGFloat = 10
            static let rightOffset: CGFloat = -14
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = .white
        
        addSubview(logoImageView)
        addSubview(nameLabel)
        addSubview(priceStackView)
    }
    
    func setConstraints() {
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.NameLabel.topOffset)
            $0.left.equalTo(logoImageView.snp.right).offset(UIConstants.NameLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.NameLabel.rightOffset)
        }
        logoImageView.snp.makeConstraints {
            $0.centerY.equalTo(nameLabel.snp.centerY)
            $0.left.equalToSuperview().offset(UIConstants.LogoImageView.leftOffset)
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
        priceStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(UIConstants.PriceStackView.topOffset)
            $0.right.equalToSuperview().offset(UIConstants.PriceStackView.rightOffset)
        }
    }
}
