//
//  SelectMenuView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: SelectMenuView
final class SelectMenuView: UIView {
    //MARK: - Properties
    lazy var titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
    }
    lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchCollectionViewLayout()).then {
        $0.backgroundColor = .white
        $0.alwaysBounceHorizontal = false
        $0.allowsMultipleSelection = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        SelectMenuCollectionViewCell.register($0)
    }
    lazy var laterButton = UIButton().then {
        let att = NSAttributedString(string: "다음에 설정", attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue])
        $0.setAttributedTitle(att, for: .normal)
        $0.setAttributedTitle(att, for: .highlighted)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .highlighted)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    let emptyView = UIView()
    
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
        alpha = 0.0
        layer.cornerRadius = 10.0
        backgroundColor = .white
        
        addSubview(titleLabel)
        addSubview(collectionView)
        addSubview(laterButton)
        addSubview(emptyView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(36)
            $0.left.right.equalToSuperview().inset(24)
            $0.height.equalTo(18)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(48)
            $0.left.right.equalToSuperview().inset(36)
        }
        laterButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(laterButton.snp.bottom).offset(24)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func fetchCollectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 24.0
        layout.minimumInteritemSpacing = 24.0
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width * 0.75) - 72, height: 50.0)
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        return layout
    }
}
