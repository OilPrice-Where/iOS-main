//
//  InfoListView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/02.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: - Configure
extension InfoListView {
    func configure(address: String?) {
        guard let address, address.isNotEmpty else {
            return
        }
        valueLabel.text = address
    }
}


//MARK: 리스트 정렬 & 위치 표시
final class InfoListView: UIView {
    //MARK: - Properties
    let priceSortedButton = UIButton().then {
        $0.tag = UIConstants.PriceSortedButton.tag
        $0.setTitle(UIConstants.PriceSortedButton.title, for: .normal)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.titleLabel?.font = UIConstants.PriceSortedButton.font
        $0.backgroundColor = .systemGroupedBackground
        $0.isSelected = true
    }
    let distanceSortedButton = UIButton().then {
        $0.tag = UIConstants.DistanceSortedButton.tag
        $0.setTitle(UIConstants.DistanceSortedButton.title, for: .normal)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.titleLabel?.font = UIConstants.DistanceSortedButton.font
        $0.backgroundColor = .systemGroupedBackground
    }
    private let geoLogoImageView = UIImageView().then {
        $0.image = UIConstants.GeoLogoImageView.image
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    private let valueLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIConstants.ValueLabel.font
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension InfoListView {
    enum UIConstants {
        enum PriceSortedButton {
            static let tag: Int = 1
            static let title: String = "가격순"
            static let font: UIFont = FontFamily.NanumSquareRound.extraBold.font(size: 16)
            
            static let leftOffset: CGFloat = 10
            static let width: CGFloat = 45
        }
        
        enum DistanceSortedButton {
            static let tag: Int = 2
            static let title: String = "거리순"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let leftOffset: CGFloat = 10
            static let width: CGFloat = 45
        }
        
        enum GeoLogoImageView {
            static let image: UIImage = Asset.Images.geoIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -3
            static let size: CGFloat = 14
        }
        
        enum ValueLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let rightOffset: CGFloat = -10
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(priceSortedButton)
        addSubview(distanceSortedButton)
        addSubview(geoLogoImageView)
        addSubview(valueLabel)
    }
    
    func setConstraints() {
        priceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(UIConstants.PriceSortedButton.leftOffset)
            $0.width.equalTo(UIConstants.PriceSortedButton.width)
        }
        distanceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(priceSortedButton.snp.right).offset(UIConstants.DistanceSortedButton.leftOffset)
            $0.width.equalTo(UIConstants.DistanceSortedButton.width)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(distanceSortedButton)
            $0.right.equalToSuperview().offset(UIConstants.ValueLabel.rightOffset)
        }
        geoLogoImageView.snp.makeConstraints {
            $0.centerY.equalTo(valueLabel)
            $0.right.equalTo(valueLabel.snp.left).offset(UIConstants.GeoLogoImageView.rightOffset)
            $0.size.equalTo(UIConstants.GeoLogoImageView.size)
        }
    }
}

