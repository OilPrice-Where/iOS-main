//
//  SearchView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: SearchView
final class HomeSearchView: UIView {
    //MARK: - Properties
    private let menuImageView = UIImageView().then {
        let image = Asset.Images.menuIcon.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = Asset.Colors.mainColor.color
    }
    let menuButton = UIButton()
    let searchImageView = UIImageView().then {
        let image = Asset.Images.search.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .systemGray3
    }
    let placeholderLabel = UILabel().then {
        $0.text = "주유소 위치를 검색해보세요."
        $0.textColor = .systemGray
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    let listButton = UIButton()
    private let listImageView = UIImageView().then {
        let image = Asset.Images.listIcon.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .white
    }
    private let listImageBackgroundView = UIView().then {
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = 20.0
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Make UI
    private func makeUI() {
        backgroundColor = .white
        layer.cornerRadius = 25
        
        addSubview(menuImageView)
        addSubview(menuButton)
        addSubview(searchImageView)
        addSubview(placeholderLabel)
        addSubview(listImageBackgroundView)
        addSubview(listImageView)
        addSubview(listButton)
        
        menuImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(28)
        }
        menuButton.snp.makeConstraints {
            $0.left.top.bottom.equalToSuperview()
            $0.width.equalTo(50)
        }
        searchImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(menuButton.snp.right)
            $0.size.equalTo(24)
        }
        placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(searchImageView.snp.right).offset(7)
        }
        listImageView.snp.makeConstraints {
            $0.center.equalTo(listImageBackgroundView)
            $0.size.equalTo(24)
        }
        listImageBackgroundView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-8)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(40)
        }
        listButton.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.width.equalTo(50)
        }
    }
}
