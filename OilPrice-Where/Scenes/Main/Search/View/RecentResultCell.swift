//
//  RecentResultCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit

protocol RecentResultCellProtocol: AnyObject {
    func delete(poi: POI?, index: Int?)
}

//MARK: SearchResultCell
final class RecentResultCell: UITableViewCell {
    //MARK: - Properties
    weak var delegate: RecentResultCellProtocol?
    private var poi: POI?
    private var index: Int?
    private let locationImageView = UIImageView().then {
        let image = Asset.Images.geoIcon.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .black
    }
    private let titleLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    private let dateLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.light.font(size: 14)
    }
    private let deleteImageView = UIImageView().then {
        let image = Asset.Images.close.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .systemGray3
    }
    private lazy var deleteButton = UIButton().then {
        $0.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
    }
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    let dateFormatter = DateFormatter().then {
        $0.dateFormat = "MM/dd"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Make UI
    private func makeUI() {
        contentView.addSubview(locationImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(deleteImageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(lineView)
        
        locationImageView.snp.makeConstraints {
            $0.left.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
        deleteButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview()
            $0.size.equalTo(38)
        }
        deleteImageView.snp.makeConstraints {
            $0.center.equalTo(deleteButton)
            $0.size.equalTo(10)
        }
        dateLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalTo(deleteButton.snp.left)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalTo(locationImageView.snp.right).offset(8)
            $0.right.equalTo(dateLabel.snp.left).offset(-8)
        }
        lineView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
            $0.height.equalTo(1)
        }
    }
    
    func configure(with poi: ResponsePOI, index: Int) {
        self.poi = DataManager.shared.pois[index]
        self.index = index
        titleLabel.text = poi.name
        dateLabel.text = dateFormatter.string(from: poi.insertDate ?? Date())
    }
    
    @objc
    private func deleteButtonTouched() {
        delegate?.delete(poi: poi, index: index)
    }
}
