//
//  CardCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Then

final class CardCollectionViewCell: UICollectionViewCell {
    // Properties
    let dummy = ["SKE", "GSC", "HDO", "SOL", "RTO", "RTX", "NHO", "ETC", "E1G", "SKG"]
    let containerView = UIView().then {
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        $0.layer.masksToBounds = true
    }
    let cardNameLabel = UILabel().then {
        $0.text = "신한카드"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        $0.textColor = .white
    }
    let saleLabel = UILabel().then {
        $0.text = "1.2% 할인"
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        $0.textColor = .white
    }
    lazy var brandCollectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.alwaysBounceHorizontal = false
        $0.allowsMultipleSelection = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        BrandCollectionViewCell.register($0)
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set UI
    func makeUI() {
        layer.shadowOffset = CGSize(width: 8, height: 8)
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowRadius = 10.0
        layer.shadowOpacity = 0.6
        
        contentView.addSubview(containerView)
        containerView.addSubview(cardNameLabel)
        containerView.addSubview(saleLabel)
        containerView.addSubview(brandCollectionView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        cardNameLabel.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(16)
        }
        
        saleLabel.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-16)
            $0.left.right.equalToSuperview().inset(16)
        }
        
        brandCollectionView.snp.makeConstraints {
            $0.top.equalTo(cardNameLabel.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.bottom.equalTo(saleLabel.snp.top).offset(-16)
        }
    }
    
    // set collectionView flow layout
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let itemSize = CGSize(width: 30, height: 30)
        
        let flowLayout = CollectionViewLeftAlignFlowLayout()
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = itemSize
        flowLayout.estimatedItemSize = UICollectionViewFlowLayoutAutomaticSize
        return flowLayout
    }
}

extension CardCollectionViewCell: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Int.random(in: 1...10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withType: BrandCollectionViewCell.self, indexPath: indexPath)
        
        cell.configure(imageName: dummy[indexPath.item])
        
        return cell
    }
}

class CollectionViewLeftAlignFlowLayout: UICollectionViewFlowLayout {
    let cellSpacing: CGFloat = 10
 
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 10.0
        self.sectionInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        let attributes = super.layoutAttributesForElements(in: rect)
 
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += 30 + cellSpacing
            maxY = max(layoutAttribute.frame.maxY, maxY)
        }
        return attributes
    }
}
