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
    private let searchImageView = UIImageView().then {
        $0.image = Asset.Images.search.image
    }
    private let placeholderLabel = UILabel().then {
        $0.text = "주유소 위치를 검색해보세요."
        $0.textColor = .systemGray
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
    }
    let filterButton = UIButton().then {
        let image = Asset.Images.filter.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.setImage(image, for: .highlighted)
        $0.tintColor = .black
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
        layer.cornerRadius = 21
        
        addSubview(searchImageView)
        addSubview(placeholderLabel)
        addSubview(filterButton)
        
        searchImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(10)
            $0.size.equalTo(20)
        }
        placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(searchImageView.snp.right).offset(7)
        }
        filterButton.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.width.equalTo(44)
        }
    }
}
