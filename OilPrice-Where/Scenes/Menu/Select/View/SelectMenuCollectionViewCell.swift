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
        $0.layer.borderWidth = 0.5
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    
    override var isSelected: Bool {
        didSet {
            titleLabel.textColor = isSelected ? .white : .black
            backgroundColor = isSelected ? Asset.Colors.mainColor.color : .white
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
            $0.edges.equalToSuperview().inset(0.5)
        }
    }
}
