//
//  GasStationView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension GasStationView {
    func configure(fuelType type: FuelType, station: GasStationSummary, isFavoriteStation: Bool) {
        titleView.configure(title: station)
        
        bottomView.configure(fuelType: type, station: station)
        updateFavoriteUI(isFavoriteStation: isFavoriteStation)
    }
}


//MARK: GasStationCell의 ContentView
final class GasStationView: UIView {
    //MARK: - Properties
    private let titleView = GasStationTitleView()
    private let bottomView = GasStationBottomView()
    private let lineView = UIView().then {
        $0.backgroundColor = UIConstants.LineView.backgroundColor
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

extension GasStationView {
    var favoriteButton: UIButton {
        bottomView.expandView.favoriteButton
    }
    
    var directionView: UIView {
        bottomView.expandView.directionView
    }
    
    func updateFavoriteUI(isFavoriteStation: Bool? = nil) {
        let isFavorite = isFavoriteStation ?? !favoriteButton.isSelected
        favoriteButton.isSelected = isFavorite
        let favoriteImage = isFavorite ? UIConstants.FavoriteButton.favoriteOnIcon : UIConstants.FavoriteButton.favoriteOffIcon
        favoriteButton.setImage(favoriteImage, for: .normal)
        let favoriteTintColor = isFavorite ? UIConstants.FavoriteButton.favoriteOnTintColor : UIConstants.FavoriteButton.favoriteOffTintColor
        favoriteButton.imageView?.tintColor = favoriteTintColor
        let favoriteBackgroundColor = isFavorite ? UIConstants.FavoriteButton.favoriteOnBackgroundColor : UIConstants.FavoriteButton.favoriteOffBackgroundColor
        favoriteButton.backgroundColor = favoriteBackgroundColor
    }
}


//MARK: - Set UI
private extension GasStationView {
    enum UIConstants {
        enum TitleView {
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 12
            static let rightOffset: CGFloat = -16
            static let height: CGFloat = 30
        }
        
        enum LineView {
            static let backgroundColor: UIColor = .init(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
            
            static let topOffset: CGFloat = 8
            static let height: CGFloat = 1.2
        }
        
        enum BottomView {
            static let topOffset: CGFloat = 8
            static let bottomOffset: CGFloat = -12
        }
        
        enum FavoriteButton {
            static let favoriteOnIcon: UIImage = Asset.Images.favoriteOnIcon.image.withRenderingMode(.alwaysTemplate)
            static let favoriteOffIcon: UIImage = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let favoriteOnTintColor: UIColor = .white
            static let favoriteOffTintColor: UIColor = Asset.Colors.mainColor.color
            
            static let favoriteOnBackgroundColor: UIColor = Asset.Colors.mainColor.color
            static let favoriteOffBackgroundColor: UIColor = .white
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = .white
        
        addSubview(titleView)
        addSubview(lineView)
        addSubview(bottomView)
    }
    
    func setConstraints() {
        titleView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.TitleView.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.TitleView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.TitleView.rightOffset)
            $0.height.equalTo(UIConstants.TitleView.height)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(UIConstants.LineView.topOffset)
            $0.left.right.equalTo(titleView)
            $0.height.equalTo(UIConstants.LineView.height)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(UIConstants.BottomView.topOffset)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview().offset(UIConstants.BottomView.bottomOffset)
        }
    }
}
