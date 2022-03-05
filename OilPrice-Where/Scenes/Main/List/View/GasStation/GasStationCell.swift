//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit

protocol GasStationCellDelegate: AnyObject {
    func touchedFavoriteButton(id: String?)
    func touchedDirectionButton(info: GasStation?)
}

//MARK: 메인페이지의 리스트 부분에서 받아오는 주유소 목록을 나타내는 셀
final class GasStationCell: UITableViewCell {
    //MARK: - Properties
    private var info: GasStation?
    var selectionCell: Bool = false
    weak var delegate: GasStationCellDelegate?
    let stationView = GasStationView().then {
        $0.bottomView.expandView.favoriteButton.addTarget(self, action: #selector(touchedFavorite), for: .touchUpInside)
    }
    lazy var tap = UITapGestureRecognizer(target: self, action: #selector(touchedDirection))
    
    //MARK: - Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        selectionCell = false
        stationView.bottomView.expandView.directionView.removeGestureRecognizer(tap)
    }
    
    //MARK: - Make UI
    func makeUI() {
        selectionStyle = .none
        backgroundColor = .systemGroupedBackground
        contentView.addSubview(stationView)
        
        stationView.layer.cornerRadius = 5
        
        stationView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.left.right.equalToSuperview().inset(16)
        }
    }
    
    func configure(station info: GasStation) {
        self.info = info
        stationView.titleView.configure(title: info)
        stationView.bottomView.priceView.configure(price: info)
        stationView.bottomView.expandView.directionView.configure(distance: Preferences.distance(km: info.distance))
        stationView.bottomView.expandView.directionView.addGestureRecognizer(tap)
    }
    
    @objc
    func touchedFavorite(sender: Any) {
        delegate?.touchedFavoriteButton(id: info?.id)
    }
    
    @objc
    func touchedDirection() {
        delegate?.touchedDirectionButton(info: info)
    }
}
