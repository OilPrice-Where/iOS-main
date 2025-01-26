//
//  GasStationExpandView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension GasStationExpandView {
    func configure(isFavorite: Bool, distance: String) {
        directionView.configure(distance: distance)
        
        let favoriteImage = isFavorite ? UIConstants.FavoriteButton.favoriteOnIcon : UIConstants.FavoriteButton.favoriteOffIcon
        favoriteButton.setImage(favoriteImage, for: .normal)
        let favoriteTintColor = isFavorite ? UIConstants.FavoriteButton.favoriteOnTintColor : UIConstants.FavoriteButton.favoriteOffTintColor
        favoriteButton.imageView?.tintColor = favoriteTintColor
        let favoriteBackgroundColor = isFavorite ? UIConstants.FavoriteButton.favoriteOnBackgroundColor : UIConstants.FavoriteButton.favoriteOffBackgroundColor
        favoriteButton.backgroundColor = favoriteBackgroundColor
    }
}


//MARK: GasStationCell의 경로안내 View
final class GasStationExpandView: UIView {
    //MARK: - Properties
    let favoriteButton = UIButton().then {
        $0.setImage(UIConstants.FavoriteButton.favoriteOffIcon, for: .normal)
        $0.imageView?.tintColor = UIConstants.FavoriteButton.favoriteOffTintColor
        $0.layer.borderWidth = UIConstants.FavoriteButton.borderWidth
        $0.layer.borderColor = UIConstants.FavoriteButton.borderColor
        $0.layer.cornerRadius = UIConstants.FavoriteButton.cornerRadius
    }
    let directionView = GasStationDirectionView()
    
    //MARK: - Initializer
    init(height: CGFloat = 40) {
        super.init(frame: .zero)
        
        makeUI(height: height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension GasStationExpandView {
    enum UIConstants {
        enum FavoriteButton {
            static let favoriteOnIcon: UIImage = Asset.Images.favoriteOnIcon.image.withRenderingMode(.alwaysTemplate)
            static let favoriteOffIcon: UIImage = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let favoriteOnTintColor: UIColor = .white
            static let favoriteOffTintColor: UIColor = Asset.Colors.mainColor.color
            
            static let favoriteOnBackgroundColor: UIColor = Asset.Colors.mainColor.color
            static let favoriteOffBackgroundColor: UIColor = .white
            
            static let borderWidth: CGFloat = 1.0
            static let borderColor: CGColor = Asset.Colors.mainColor.color.cgColor
            static let cornerRadius: CGFloat = 5
            
            static let leftOffset: CGFloat = 16
            static let width: CGFloat = 80
        }
        
        enum DirectionView {
            static let leftOffset: CGFloat = 15
            static let rightOffset: CGFloat = -16
        }
    }
    
    func makeUI(height: CGFloat) {
        configureUI()
        setConstraints(contentHeight: height)
    }
    
    func configureUI() {
        backgroundColor = .white
        
        addSubview(favoriteButton)
        addSubview(directionView)
    }
    
    func setConstraints(contentHeight: CGFloat) {
        favoriteButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(UIConstants.FavoriteButton.leftOffset)
            $0.width.equalTo(UIConstants.FavoriteButton.width)
            $0.height.equalTo(contentHeight)
        }
        directionView.snp.makeConstraints {
            $0.left.equalTo(favoriteButton.snp.right).offset(UIConstants.DirectionView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DirectionView.rightOffset)
            $0.top.bottom.equalToSuperview()
        }
    }
}
