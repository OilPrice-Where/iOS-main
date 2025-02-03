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
    
    func updateSortButton(isPriceSort: Bool) {
        priceSortedButton.isSelected = isPriceSort
        distanceSortedButton.isSelected = !isPriceSort
        
        if isPriceSort {
            priceSortedButton.titleLabel?.font = UIConstants.SortButton.selectedFont
            distanceSortedButton.titleLabel?.font = UIConstants.SortButton.normalFont
        } else {
            priceSortedButton.titleLabel?.font = UIConstants.SortButton.normalFont
            distanceSortedButton.titleLabel?.font = UIConstants.SortButton.selectedFont
        }
    }
}


//MARK: 리스트 정렬 & 위치 표시
final class InfoListView: UIView {
    //MARK: - Properties
    let priceSortedButton = UIButton().then {
        $0.tag = UIConstants.SortButton.Price.tag
        $0.setTitle(UIConstants.SortButton.Price.title, for: .normal)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.mainColor.color, for: .normal)
        $0.titleLabel?.font = UIConstants.SortButton.selectedFont
        $0.isSelected = true
    }
    let distanceSortedButton = UIButton().then {
        $0.tag = UIConstants.SortButton.Distance.tag
        $0.setTitle(UIConstants.SortButton.Distance.title, for: .normal)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.mainColor.color, for: .normal)
        $0.titleLabel?.font = UIConstants.SortButton.normalFont
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
        enum SortButton {
            static let leftOffset: CGFloat = 10
            static let width: CGFloat = 45
            
            static let normalFont: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            static let selectedFont: UIFont = FontFamily.NanumSquareRound.extraBold.font(size: 16)
            
            enum Price {
                static let tag: Int = 1
                static let title: String = "가격순"
            }
            
            enum Distance {
                static let tag: Int = 2
                static let title: String = "거리순"
            }
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
        backgroundColor = .systemGroupedBackground
        
        addSubview(priceSortedButton)
        addSubview(distanceSortedButton)
        addSubview(geoLogoImageView)
        addSubview(valueLabel)
    }
    
    func setConstraints() {
        priceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(UIConstants.SortButton.leftOffset)
            $0.width.equalTo(UIConstants.SortButton.width)
        }
        distanceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(priceSortedButton.snp.right).offset(UIConstants.SortButton.leftOffset)
            $0.width.equalTo(UIConstants.SortButton.width)
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

