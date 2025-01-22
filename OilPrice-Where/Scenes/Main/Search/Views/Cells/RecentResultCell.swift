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


protocol RecentResultCellDelegate: AnyObject {
    func delete(poi: SearchPOI)
}


extension RecentResultCell {
    static func cellRegistration(_ delegate: RecentResultCellDelegate) -> UICollectionView.CellRegistration<RecentResultCell, SearchPOI> {
        return UICollectionView.CellRegistration { cell, indexPath, poi in
            cell.delegate = delegate
            cell.configure(with: poi)
        }
    }
    
    private func configure(with poi: SearchPOI) {
        self.poi = poi
        titleLabel.text = poi.name
        dateLabel.text = dateFormatter.string(from: poi.insertDate)
    }
}


//MARK: RecentResultCell
final class RecentResultCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: RecentResultCellDelegate?
    private var poi: SearchPOI?
    
    private let locationImageView = UIImageView().then {
        $0.image = UIConstants.LocationImageView.image
        $0.tintColor = .black
    }
    private let titleLabel = UILabel().then {
        $0.font = UIConstants.TitleLabel.font
    }
    private let dateLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIConstants.DateLabel.font
    }
    private let deleteImageView = UIImageView().then {
        $0.image = UIConstants.DeleteImageView.image
        $0.tintColor = .systemGray3
    }
    private let deleteButton = UIButton()
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    private let dateFormatter = DateFormatter().then {
        $0.dateFormat = "MM/dd"
        $0.locale = Locale(identifier: "ko_KR")
    }
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        configureDeleteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureDeleteButton() {
        deleteButton.addTarget(self, action: #selector(deleteButtonTouched), for: .touchUpInside)
    }
    
    @objc
    private func deleteButtonTouched() {
        guard let poi else {
            return
        }
        delegate?.delete(poi: poi)
    }
}


// MARK: - Set UI
private extension RecentResultCell {
    enum UIConstants {
        enum ContentView {
            static let height: CGFloat = 50
        }
        
        enum LocationImageView {
            static let image: UIImage = Asset.Images.geoIcon.image.withRenderingMode(.alwaysTemplate)
            
            static let size: CGFloat = 20
        }
        
        enum TitleLabel {
            static let font = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let leftOffset: CGFloat = 8
            static let rightOffset: CGFloat = -8
        }
        
        enum DateLabel {
            static let font = FontFamily.NanumSquareRound.light.font(size: 14)
        }
        
        enum DeleteImageView {
            static let image: UIImage = Asset.Images.close.image.withRenderingMode(.alwaysTemplate)
            
            static let size: CGFloat = 10
        }
        
        enum DeleteButton {
            static let size: CGFloat = 38
            static let lineHeight: CGFloat = 1
        }
        
        enum LineView {
            static let height: CGFloat = 1
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        contentView.addSubview(locationImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(deleteImageView)
        contentView.addSubview(deleteButton)
        contentView.addSubview(lineView)
    }
    
    func setConstraints() {
        locationImageView.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(UIConstants.LocationImageView.size)
        }
        deleteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.size.equalTo(UIConstants.DeleteButton.size)
        }
        deleteImageView.snp.makeConstraints { make in
            make.center.equalTo(deleteButton)
            make.size.equalTo(UIConstants.DeleteImageView.size)
        }
        dateLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(deleteButton.snp.left)
        }
        titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(locationImageView.snp.right).offset(UIConstants.TitleLabel.leftOffset)
            make.right.equalTo(dateLabel.snp.left).offset(UIConstants.TitleLabel.rightOffset)
        }
        lineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIConstants.LineView.height)
        }
    }
}
