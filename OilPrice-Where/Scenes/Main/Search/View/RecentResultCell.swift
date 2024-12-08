//
//  RecentResultCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


protocol RecentResultCellProtocol: AnyObject {
    func delete(poi: POIEntity?, index: Int?)
}

//MARK: RecentResultCell
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
        
        setupUI()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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


// MARK: - UI Setup
private extension RecentResultCell {
    enum UIConstants {
        static let locationImageSize: CGFloat = 20
        static let deleteButtonSize: CGFloat = 38
        static let deleteImageSize: CGFloat = 10
        static let interItemSpacing: CGFloat = 8
        static let lineHeight: CGFloat = 1
    }
    
    func setupUI() {
        contentView.addSubview(locationImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(deleteImageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(lineView)
    }
    
    func setupConstraints() {
        locationImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(UIConstants.locationImageSize)
        }
                
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.size.equalTo(UIConstants.deleteButtonSize)
        }
        
        deleteImageView.snp.makeConstraints { make in
            make.center.equalTo(deleteButton)
            make.size.equalTo(UIConstants.deleteImageSize)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(deleteButton.snp.left)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(locationImageView.snp.right).offset(UIConstants.interItemSpacing)
            make.right.equalTo(dateLabel.snp.left).offset(-UIConstants.interItemSpacing)
        }
        
        lineView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIConstants.lineHeight)
        }
    }
}
