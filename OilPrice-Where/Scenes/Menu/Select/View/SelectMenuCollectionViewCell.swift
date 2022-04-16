//
//  SelectMenuCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

//MARK: 즐겨찾는 주유소 Cell
import Then
import SnapKit
import UIKit
//MARK: SelectMenuCollectionViewCell
final class SelectMenuCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    let titleLabel = UILabel().then {
        $0.textColor = .black
        $0.textAlignment = .center
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 5
        $0.layer.borderWidth = 0.5
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    
    override var isSelected: Bool {
        didSet {
            contentView.layer.borderWidth = isSelected ? 0.0 : 0.5
            titleLabel.textColor = isSelected ? .white : .black
            titleLabel.backgroundColor = isSelected ? Asset.Colors.mainColor.color : .white
            titleLabel.layer.borderWidth = isSelected ? 0.0 : 0.5
        }
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
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
