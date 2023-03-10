//
//  BrandTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 03/01/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SwiftUI

//MARK: 탐색 브랜드 Cell
final class BrandTypeTableViewCell: UITableViewCell {
    // Properties
    @Published var name = ""
    private var viewModel = FindBrandViewModel()
    private let brandTypeLable = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    let brandSelectedSwitch = UISwitch().then {
        $0.onTintColor = Asset.Colors.mainColor.color
    }
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure Data
    func fetchData(brand name: String) {
        // 검색할 브랜드 이름
        self.name = name
        self.brandTypeLable.text = name
    }
    
    // Set UI
    private func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(brandTypeLable)
        contentView.addSubview(brandSelectedSwitch)
        
        brandSelectedSwitch.snp.makeConstraints {
            $0.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(50)
        }
        
        brandTypeLable.snp.makeConstraints {
            $0.left.equalToSuperview().offset(20)
            $0.right.equalTo(brandSelectedSwitch.snp.left).offset(-10)
            $0.centerY.equalToSuperview()
        }
        
    }
    
    private func bind() {
        $name
            .receive(on: DispatchQueue.main)
            .sink { [weak self] brandName in
                guard brandName != "전체" else { return }
                
                let brands = DefaultData.shared.brandsSubject.value
                let isContains = brands.contains(Preferences.brand(name: brandName))
                self?.brandSelectedSwitch.isOn = isContains
            }
            .store(in: &viewModel.cancelBag)
        
        DefaultData.shared.brandsSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] brands in
                guard let owner = self, owner.name == "전체" else { return }
                owner.brandSelectedSwitch.isOn = brands.count == 10
            }
            .store(in: &viewModel.cancelBag)
        
        
        brandSelectedSwitch
            .isOnPublisher
            .sink { [weak self] isOn in
                guard let owner = self, !owner.name.isEmpty else { return }
                
                var brands = DefaultData.shared.brandsSubject.value
                
                let code = Preferences.brand(name: owner.name)
                
                if isOn {
                    if !brands.contains(code) { brands.append(code) }
                } else {
                    brands = brands.filter { $0 != code }
                }
                
                if owner.name == "전체" {
                    DefaultData.shared.brandsSubject.send(isOn ? owner.viewModel.allBrands : [])
                } else {
                    DefaultData.shared.brandsSubject.send(brands)
                }
            }
            .store(in: &viewModel.cancelBag)
    }
}
