//
//  BrandCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/05.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: BrandCollectionViewCell
final class BrandCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
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
    func makeUI() {
        contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configure(imageName: String?) {
        let image = Preferences.logoImage(logoName: imageName)
        imageView.image = image
    }
}
