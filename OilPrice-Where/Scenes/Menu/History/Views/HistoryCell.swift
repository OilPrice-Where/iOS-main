//
//  HistoryCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension HistoryCell {
    static let cellRegistration = UICollectionView.CellRegistration<HistoryCell, VisitedGasStation> { cell, indexPath, station in
        cell.configure(station: station)
    }
    
    private func configure(station: VisitedGasStation) {
        let brandImage = StationBrand(code: station.brand).image
        brandImageView.image = brandImage
        stationNameLabel.text = station.name
        visitValueLabel.text = formatter.string(for: station.visitDate)
        
        let priceString = station.recordedPrice.decimalNumber
        let fuelName = FuelType(code: station.fuelCode).name
        priceValueLabel.text = fuelName + " | " + (priceString != "0" ? priceString : "가격 정보 없음")
    }
}

//MARK: HistoryTableViewCell
final class HistoryCell: UICollectionViewCell {
    let formatter = DateFormatter().then {
        $0.dateStyle = .long
        $0.timeStyle = .short
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    //MARK: - Properties
    
    let brandImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let stationNameLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
        $0.textAlignment = .left
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    }
    let priceKeyLabel = UILabel().then {
        $0.text = "방문 가격"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var priceValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    let visitKeyLabel = UILabel().then {
        $0.text = "방문 일자"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var visitValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: .zero)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        resetUI()
    }
}

// MARK: - Set UI
private extension HistoryCell {
    enum UIConstants {
        // Offset & Spacing
        static let topOffset: CGFloat = 16
        static let leftOffset: CGFloat = 12
        static let betweenOffset: CGFloat = 8
        static let stationNameHeight: CGFloat = 30
        static let priceKeyTopOffset: CGFloat = 18
        static let visitKeyTopOffset: CGFloat = 12
        
        // Size
        static let contentViewHeight: CGFloat = 127.0
        static let brandImageSize: CGFloat = 30
        
        // Right Inset
        static let rightInset: CGFloat = -16
        static let valueRightInset: CGFloat = -12
        
        // Additional Offsets
        static let priceValueOffset: CGFloat = 5
        static let visitValueOffset: CGFloat = 5
    }
    
    func makeUI() {
        configureUI()
        setupConstraints()
    }
    
    func resetUI() {
        priceValueLabel.text = nil
        visitValueLabel.text = nil
    }
    
    func configureUI() {
        contentView.addSubview(brandImageView)
        contentView.addSubview(stationNameLabel)
        contentView.addSubview(priceKeyLabel)
        contentView.addSubview(priceValueLabel)
        contentView.addSubview(visitKeyLabel)
        contentView.addSubview(visitValueLabel)
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.height.equalTo(UIConstants.contentViewHeight)
        }
        
        brandImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.leftOffset)
            $0.size.equalTo(UIConstants.brandImageSize)
        }
        
        stationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.topOffset)
            $0.left.equalTo(brandImageView.snp.right).offset(UIConstants.betweenOffset)
            $0.right.equalToSuperview().offset(UIConstants.rightInset)
            $0.height.equalTo(UIConstants.stationNameHeight)
        }
        
        priceKeyLabel.snp.makeConstraints {
            $0.top.equalTo(stationNameLabel.snp.bottom).offset(UIConstants.priceKeyTopOffset)
            $0.left.equalToSuperview().offset(UIConstants.leftOffset)
        }
        
        priceValueLabel.snp.makeConstraints {
            $0.top.equalTo(priceKeyLabel.snp.top)
            $0.left.equalTo(priceKeyLabel.snp.right).offset(UIConstants.priceValueOffset)
            $0.right.equalToSuperview().offset(UIConstants.valueRightInset)
        }
        
        visitKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceKeyLabel.snp.bottom).offset(UIConstants.visitKeyTopOffset)
            $0.left.equalToSuperview().offset(UIConstants.leftOffset)
        }
        
        visitValueLabel.snp.makeConstraints {
            $0.top.equalTo(visitKeyLabel.snp.top)
            $0.left.equalTo(visitKeyLabel.snp.right).offset(UIConstants.visitValueOffset)
            $0.right.equalToSuperview().offset(UIConstants.valueRightInset)
        }
    }
}
