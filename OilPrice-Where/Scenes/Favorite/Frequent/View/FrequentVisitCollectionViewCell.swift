//
//  FrequentVisitCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit

protocol FrequentVisitCollectionViewCellDelegate: AnyObject {
    func touchedFavoriteButton(id: String?)
    func touchedDirectionButton(info: Station?)
}
//MARK: FrequentVisitCollectionViewCell
final class FrequentVisitCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    private var info: Station?
    weak var delegate: FrequentVisitCollectionViewCellDelegate?
    let titleView = GasStationTitleView()
    lazy var expandView = GasStationExpandView().then {
        $0.favoriteButton.addTarget(self, action: #selector(self.touchedFavorite(sender:)), for: .touchUpInside)
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.touchedDirection))
        $0.directionView.addGestureRecognizer(tap)
    }
    let countLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 10)
        $0.textColor = .white
        $0.textAlignment = .center
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }
    let lineView = UIView().then {
        $0.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
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
        backgroundColor = .white
        
        layer.cornerRadius = 5.0
        
        contentView.addSubview(countLabel)
        contentView.addSubview(titleView)
        contentView.addSubview(expandView)
        contentView.addSubview(lineView)
        
        expandView.directionView.configure(msg: "길 찾기")
        expandView.directionView.configure(image: Asset.Images.navigationIcon.image.withTintColor(.white, renderingMode: .alwaysTemplate))
        
        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.height.equalTo(20)
            $0.width.equalTo(60)
        }
        titleView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(30)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.left.right.equalTo(titleView)
            $0.height.equalTo(1.2)
        }
        expandView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    func configure(station: Station) {
        info = station
        countLabel.text = "\(station.count)회 방문"
        titleView.configure(staion: station)
        updateFavoriteUI(favoriteID: station.identifier)
    }
    
    private func updateFavoriteUI(favoriteID: String?) {
        guard let id = favoriteID else { return }
        
        let ids = DefaultData.shared.favoriteSubject.value
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        expandView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        expandView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
        expandView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
    }
    
    @objc
    private func touchedFavorite(sender: Any) {
        delegate?.touchedFavoriteButton(id: info?.identifier)
    }
    
    @objc
    private func touchedDirection() {
        delegate?.touchedDirectionButton(info: info)
    }
}
