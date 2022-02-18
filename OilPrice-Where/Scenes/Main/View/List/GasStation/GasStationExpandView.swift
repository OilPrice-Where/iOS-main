//
//  GasStationExpandView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: GasStationCell의 경로안내 View
final class GasStationExpandView: UIView {
    //MARK: - Properties
    let favoriteButton = UIButton().then {
        let image = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(image, for: .normal)
        $0.imageView?.tintColor = Asset.Colors.mainColor.color
        $0.layer.borderWidth = 1.0
        $0.layer.borderColor = Asset.Colors.mainColor.color.cgColor
        $0.layer.cornerRadius = 5
    }
    let directionView = GasStationDirectionView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Make UI
    func makeUI() {
        addSubview(favoriteButton)
        addSubview(directionView)
        
        favoriteButton.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
            $0.width.equalToSuperview().dividedBy(4)
        }
        
        directionView.snp.makeConstraints {
            $0.left.equalTo(favoriteButton.snp.right).offset(15)
            $0.right.equalToSuperview().offset(-16)
            $0.top.bottom.equalToSuperview()
        }
    }
}
