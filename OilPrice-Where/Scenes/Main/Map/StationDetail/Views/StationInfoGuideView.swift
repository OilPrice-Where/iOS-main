//
//  StationInfoGuideView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/07.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: StationInfo의 길 안내 & 즐겨찾기
final class StationInfoGuideView: UIView {
    //MARK: - Properties
    let favoriteButton = UIButton().then {
        $0.setImage(UIConstants.FavoriteButton.image, for: .normal)
        $0.layer.borderWidth = UIConstants.FavoriteButton.borderWidth
        $0.layer.borderColor = Asset.Colors.mainColor.color.cgColor
        $0.layer.cornerRadius = UIConstants.FavoriteButton.cornerRadius
        $0.imageView?.tintColor = Asset.Colors.mainColor.color
    }
    let directionButton = UIButton().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = UIConstants.DirectionButton.cornerRadius
        $0.titleLabel?.font = UIConstants.DirectionButton.font
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.textAlignment = .center
        $0.backgroundColor = Asset.Colors.mainColor.color
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
private extension StationInfoGuideView {
    enum UIConstants {
        enum FavoriteButton {
            static let image: UIImage = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
            static let borderWidth: CGFloat = 1.5
            static let cornerRadius: CGFloat = 5
            
            static let topOffset: CGFloat = 14
            static let leftOffset: CGFloat = 14
            static let width: CGFloat = 80
            static let height: CGFloat = 50
        }
        
        enum DirectionButton {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 18)
            static let cornerRadius: CGFloat = 5
            
            static let topOffset: CGFloat = 14
            static let leftOffset: CGFloat = 10
            static let rightOffset: CGFloat = -14
            static let height: CGFloat = 80
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = .white
        
        addSubview(favoriteButton)
        addSubview(directionButton)
    }
    
    func setConstraints() {
        favoriteButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.FavoriteButton.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.FavoriteButton.leftOffset)
            $0.width.equalTo(UIConstants.FavoriteButton.width)
            $0.height.equalTo(UIConstants.FavoriteButton.height)
        }
        directionButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.DirectionButton.topOffset)
            $0.left.equalTo(favoriteButton.snp.right).offset(UIConstants.DirectionButton.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DirectionButton.rightOffset)
            $0.height.equalTo(UIConstants.DirectionButton.height)
        }
    }
}
