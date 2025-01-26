//
//  InfoListView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/02.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit

//MARK: 리스트 정렬 & 위치 표시
final class InfoListView: UIView {
    //MARK: - Properties
    let priceSortedButton = UIButton().then {
        $0.tag = 1
        $0.setTitle("가격순", for: .normal)
        $0.setTitle("가격순", for: .highlighted)
        $0.isSelected = true
        $0.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.darkMain.color, for: .selected)
        $0.backgroundColor = .systemGroupedBackground
    }
    let distanceSortedButton = UIButton().then {
        $0.tag = 2
        $0.setTitle("거리순", for: .normal)
        $0.setTitle("거리순", for: .highlighted)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.setTitleColor(Asset.Colors.defaultColor.color, for: .normal)
        $0.setTitleColor(Asset.Colors.darkMain.color, for: .selected)
        $0.backgroundColor = .systemGroupedBackground
    }
    private let geoLogoImageView = UIImageView().then {
        let image = Asset.Images.geoIcon.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .black
        $0.contentMode = .scaleAspectFit
    }
    private let valueLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        addSubview(priceSortedButton)
        addSubview(distanceSortedButton)
        addSubview(geoLogoImageView)
        addSubview(valueLabel)
        
        priceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.width.equalTo(45)
        }
        distanceSortedButton.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalTo(priceSortedButton.snp.right).offset(10)
            $0.width.equalTo(45)
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(distanceSortedButton)
            $0.right.equalToSuperview().offset(-10)
        }
        geoLogoImageView.snp.makeConstraints {
            $0.size.equalTo(14)
            $0.right.equalTo(valueLabel.snp.left).offset(-3)
            $0.centerY.equalTo(valueLabel)
        }

    }
    //MARK: - Configure reverse geocoding
    func fetch(geoCode: String?) {
        guard let geoCode = geoCode else { return }
        valueLabel.text = geoCode
    }
}
