//
//  HistoryTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import UIKit
import SnapKit
//MARK: HistoryTableViewCell
final class HistoryTableViewCell: UITableViewCell {
    let formatter: DateFormatter = {
        let f = DateFormatter()
        f.dateStyle = .long
        f.timeStyle = .short
        f.locale = Locale(identifier: "ko_KR")
        return f
    }()
    
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
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        priceValueLabel.text = nil
        visitValueLabel.text = nil
    }
    
    //MARK: - Make UI
    func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(brandImageView)
        contentView.addSubview(stationNameLabel)
        contentView.addSubview(priceKeyLabel)
        contentView.addSubview(priceValueLabel)
        contentView.addSubview(visitKeyLabel)
        contentView.addSubview(visitValueLabel)
        
        brandImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalToSuperview().offset(12)
            $0.size.equalTo(30)
        }
        stationNameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.left.equalTo(brandImageView.snp.right).offset(8)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(30)
        }
        priceKeyLabel.snp.makeConstraints {
            $0.top.equalTo(stationNameLabel.snp.bottom).offset(18)
            $0.left.equalToSuperview().offset(12)
        }
        priceValueLabel.snp.makeConstraints {
            $0.top.equalTo(priceKeyLabel.snp.top)
            $0.left.equalTo(priceKeyLabel.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-12)
        }
        visitKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceKeyLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(12)
        }
        visitValueLabel.snp.makeConstraints {
            $0.top.equalTo(visitKeyLabel.snp.top)
            $0.left.equalTo(visitKeyLabel.snp.right).offset(5)
            $0.right.equalToSuperview().offset(-12)
        }
    }
    
    func configure(station: Station) {
        brandImageView.image = Preferences.logoImage(logoName: station.brand)
        stationNameLabel.text = station.name
        visitValueLabel.text = formatter.string(for: station.insertDate)
        
        let priceString = Preferences.priceToWon(price: Int(station.price))
        priceValueLabel.text = Preferences.oil(code: station.oilType ?? "") + " | " + (priceString != "0" ? priceString : "가격 정보 없음")
    }
}

