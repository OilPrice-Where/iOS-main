//
//  HomeToolbarView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension HomeToolbarView {
    func configure(searchText: String = "") {
        let isSearched = searchText.isNotEmpty
        searchImageView.tintColor = isSearched ? .black : .systemGray3
        placeholderLabel.text = isSearched ? searchText : UIConstants.PlaceholderLabel.text
        placeholderLabel.textColor = isSearched ? .black : .systemGray3
    }
}


//MARK: 홈의 세부적인 기능으로 이동할 수 있는 Toolbar(메뉴, 검색, 주유소 리스트)
final class HomeToolbarView: UIView {
    //MARK: - Properties
    let menuButton = UIButton()
    private let menuImageView = UIImageView().then {
        $0.image = UIConstants.MenuImageView.image
        $0.tintColor = Asset.Colors.mainColor.color
    }
    private let searchImageView = UIImageView().then {
        $0.image = UIConstants.SearchImageView.image
        $0.tintColor = .systemGray3
    }
    private let placeholderLabel = UILabel().then {
        $0.text = UIConstants.PlaceholderLabel.text
        $0.textColor = .systemGray
        $0.font = UIConstants.PlaceholderLabel.font
    }
    let listButton = UIButton()
    private let listImageView = UIImageView().then {
        $0.image = UIConstants.ListImageView.image
        $0.tintColor = .white
    }
    private let listImageBackgroundView = UIView().then {
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = UIConstants.ListImageBackgroundView.cornerRadius
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
private extension HomeToolbarView {
    enum UIConstants {
        enum ContentView {
            static let cornerRadius: CGFloat = 25
        }
        
        enum MenuButton {
            static let width: CGFloat = 50
        }
        
        enum MenuImageView {
            static let image: UIImage = Asset.Images.menuIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let leftOffset: CGFloat = 12
            static let size: CGFloat = 28
        }
        
        enum SearchImageView {
            static let image: UIImage = Asset.Images.search.image.withRenderingMode(.alwaysTemplate)
            
            static let size: CGFloat = 24
        }
        
        enum PlaceholderLabel {
            static let text: String = "주유소 위치를 검색해보세요."
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let leftOffset: CGFloat = 7
        }
        
        enum ListButton {
            static let width: CGFloat = 50
        }
        
        enum ListImageView {
            static let image: UIImage = Asset.Images.listIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let size: CGFloat = 24
        }
        
        enum ListImageBackgroundView {
            static let image: UIImage = Asset.Images.menuIcon.image.withRenderingMode(.alwaysTemplate)
            static let cornerRadius: CGFloat = 20
            
            static let rightOffset: CGFloat = -8
            static let size: CGFloat = 40
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = .white
        layer.cornerRadius = UIConstants.ContentView.cornerRadius
        
        addSubview(menuImageView)
        addSubview(menuButton)
        addSubview(searchImageView)
        addSubview(placeholderLabel)
        addSubview(listImageBackgroundView)
        addSubview(listImageView)
        addSubview(listButton)
    }
    
    func setConstraints() {
        menuImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.MenuImageView.leftOffset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(UIConstants.MenuImageView.size)
        }
        menuButton.snp.makeConstraints {
            $0.left.verticalEdges.equalToSuperview()
            $0.width.equalTo(UIConstants.MenuButton.width)
        }
        searchImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(menuButton.snp.right)
            $0.size.equalTo(UIConstants.SearchImageView.size)
        }
        placeholderLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(searchImageView.snp.right).offset(UIConstants.PlaceholderLabel.leftOffset)
        }
        listImageView.snp.makeConstraints {
            $0.center.equalTo(listImageBackgroundView)
            $0.size.equalTo(UIConstants.ListImageView.size)
        }
        listImageBackgroundView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(UIConstants.ListImageBackgroundView.rightOffset)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(UIConstants.ListImageBackgroundView.size)
        }
        listButton.snp.makeConstraints {
            $0.top.right.bottom.equalToSuperview()
            $0.width.equalTo(UIConstants.ListButton.width)
        }
    }
}
