//
//  FindBrandCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 03/01/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit
import SnapKit


extension FindBrandCell {
    static func cellRegistration(_ delegate: FindBrandCellDelegate) -> UICollectionView.CellRegistration<FindBrandCell, FindBrandViewModel.Brand> {
        return UICollectionView.CellRegistration<FindBrandCell, FindBrandViewModel.Brand> { cell, indexPath, brand in
            cell.delegate = delegate
            cell.configure(brand: brand)
        }
    }
    
    // Configure Data
    private func configure(brand: FindBrandViewModel.Brand) {
        self.brand = brand
        self.brandTypeLable.text = brand.name
        self.brandSelectedSwitch.isOn = brand.isSearchedBrand
    }
}

protocol FindBrandCellDelegate: AnyObject {
    func findBrandCell(_ cell: FindBrandCell, didToggleSearchFor brand: FindBrandViewModel.Brand)
}

//MARK: 탐색 브랜드 Cell
final class FindBrandCell: UICollectionViewCell {
    
    //MARK: - Properties
    private var brand: FindBrandViewModel.Brand?
    private weak var delegate: FindBrandCellDelegate?
    
    private let brandTypeLable = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    private lazy var brandSelectedSwitch = UISwitch().then {
        $0.onTintColor = Asset.Colors.mainColor.color
        $0.addTarget(self, action: #selector(toggleSearchSwitch(_:)), for: .valueChanged)
    }
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        
        makeUI()
    }
    
    @objc
    private func toggleSearchSwitch(_ sender: UISwitch) {
        guard let brand else {
            return
        }
        
        let updateBrand: FindBrandViewModel.Brand = .init(
            code: brand.code,
            name: brand.name,
            isSearchedBrand: sender.isOn
        )
        delegate?.findBrandCell(self, didToggleSearchFor: updateBrand)
    }
}


//MARK: - Set UI
private extension FindBrandCell {
    enum UIConstants {
        static let contentViewHeight: CGFloat = 17
        
        static let brandTypeLabelLeftInset: CGFloat = 20
        static let brandSelectedSwitchRightInset: CGFloat = 20
        static let brandSelectedSwitchWidth: CGFloat = 50
        static let brandTypeLabelRightToSwitchOffset: CGFloat = -10
    }
    
    func makeUI() {
        configureUI()
        setupConstraints()
    }
    
    func configureUI() {
        contentView.addSubview(brandTypeLable)
        contentView.addSubview(brandSelectedSwitch)
    }
    
    func setupConstraints() {
        contentView.snp.makeConstraints { make in
            make.height.equalTo(UIConstants.contentViewHeight)
        }
        
        brandSelectedSwitch.snp.makeConstraints {
            $0.right.equalToSuperview().inset(UIConstants.brandSelectedSwitchRightInset)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(UIConstants.brandSelectedSwitchWidth)
        }
        
        brandTypeLable.snp.makeConstraints {
            $0.left.equalToSuperview().offset(UIConstants.brandTypeLabelLeftInset)
            $0.right.equalTo(brandSelectedSwitch.snp.left).offset(UIConstants.brandTypeLabelRightToSwitchOffset)
            $0.centerY.equalToSuperview()
        }
    }
}
