//
//  SearchResultCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


extension SearchResultCell {
    static var cellRegistration: UICollectionView.CellRegistration<SearchResultCell, SearchBarViewModel.SearchResultItem> {
        return UICollectionView.CellRegistration { cell, indexPath, item in
            cell.configure(with: item)
        }
    }
    
    private func configure(with item: SearchBarViewModel.SearchResultItem) {
        let attrString = NSMutableAttributedString(string: item.poi.name)
        titleLabel.attributedText = attrString.apply(
            word: item.searchText,
            attrs: [.foregroundColor: UIColor.black]
        )
        subTitleLabel.text = item.poi.address
        
        if let departure = LocationManager.shared.currentLocation {
            let distance = departure.distance(from: item.poi.coordinate.location)
            let distanceString = distance < 1000 ? "\(Int(distance))m" : "\(Double(Int(distance * 10 / 1000)) / 10)km"
            distanceLabel.text = distanceString
        }
    }
}


//MARK: SearchResultCell
final class SearchResultCell: UICollectionViewCell {
    //MARK: - Properties
    private let titleLabel = UILabel().then {
        $0.textColor = .systemGray4
        $0.font = UIConstants.TitleLabel.font
    }
    private let subTitleLabel = UILabel().then {
        $0.textColor = .systemGray3
        $0.font = UIConstants.SubTitleLabel.font
    }
    private let distanceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIConstants.DistanceLabel.font
    }
    private let lineView = UIView().then {
        $0.backgroundColor = .systemGray5
    }
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


// MARK: - UI Setup
private extension SearchResultCell {
    enum UIConstants {
        enum TitleLabel {
            static let font = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let topInset: CGFloat = 16
            static let height: CGFloat = 26
        }
        
        enum DistanceLabel {
            static let font = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let topOffset: CGFloat = 4
        }
        
        enum SubTitleLabel {
            static let font = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let topOffset: CGFloat = 4
            static let rightOffset: CGFloat = -4
        }
        
        enum LineView {
            static let font = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let height: CGFloat = 1
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(subTitleLabel)
        contentView.addSubview(distanceLabel)
        contentView.addSubview(lineView)
    }
    
    func setConstraints() {
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(UIConstants.TitleLabel.topInset)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(UIConstants.TitleLabel.height)
        }
        distanceLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.DistanceLabel.topOffset)
            make.right.equalToSuperview()
        }
        subTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.SubTitleLabel.topOffset)
            make.left.equalToSuperview()
            make.right.equalTo(distanceLabel.snp.left).offset(UIConstants.SubTitleLabel.rightOffset)
        }
        lineView.snp.makeConstraints { make in
            make.horizontalEdges.equalToSuperview()
            make.bottom.equalToSuperview()
            make.height.equalTo(UIConstants.LineView.height)
        }
    }
}
