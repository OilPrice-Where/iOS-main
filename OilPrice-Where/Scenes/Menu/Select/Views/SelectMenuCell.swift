//
//  SelectMenuCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: 즐겨찾는 주유소 Cell
final class SelectMenuCell: UICollectionViewCell {
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
            updateUI()
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
}


//MARK: - Set UI
private extension SelectMenuCell {
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func updateUI() {
        contentView.layer.borderWidth = isSelected ? .zero : 0.5
        titleLabel.textColor = isSelected ? .white : .black
        titleLabel.backgroundColor = isSelected ? Asset.Colors.mainColor.color : .white
        titleLabel.layer.borderWidth = isSelected ? .zero : 0.5
    }
    
    func configureUI() {
        addSubview(titleLabel)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
