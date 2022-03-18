//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

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
    private var path: IndexPath?
    private var info: GasStation?
    private var selectionCell: Bool = false
    weak var delegate: GasStationCellDelegate?
    private let stationView = GasStationView().then {
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
    
    private func updateFavoriteUI(favoriteID id: String) {
        let ids = DefaultData.shared.favoriteSubject.value
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        stationView.bottomView.expandView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        stationView.bottomView.expandView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
        stationView.bottomView.expandView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
    }
    
    //MARK: - Method
    override func prepareForReuse() {
        super.prepareForReuse()
        
        path = nil
        info = nil
        selectionCell = false
        stationView.bottomView.expandView.directionView.removeGestureRecognizer(tap)
    }
    
    func configure(station info: GasStation, indexPath: IndexPath?) {
        self.info = info
        self.path = indexPath
        stationView.titleView.configure(title: info)
        stationView.bottomView.priceView.configure(price: info)
        stationView.bottomView.expandView.directionView.configure(distance: Preferences.distance(km: info.distance))
        stationView.bottomView.expandView.directionView.addGestureRecognizer(tap)
        updateFavoriteUI(favoriteID: info.id)
    }
    
    @objc
    private func touchedFavorite(sender: Any) {
        delegate?.touchedFavoriteButton(id: info?.id)
    }
    
    @objc
    private func touchedDirection() {
        delegate?.touchedDirectionButton(info: info)
    }
}
