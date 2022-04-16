//
//  BrandTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 03/01/2019.
//  Copyright © 2019 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
//MARK: 탐색 브랜드 Cell
final class BrandTypeTableViewCell: UITableViewCell {
    // Properties
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Configure Data
    func fetchData(brand name: String) {
        // 검색할 브랜드 이름
        brandTypeLable.text = name
        
        DefaultData.shared.brandsSubject
            .map { $0.contains(Preferences.brand(name: name)) }
            .bind(to: brandSelectedSwitch.rx.isOn)
            .disposed(by: rx.disposeBag)
        
        guard name != "전체" else {
            brandSelectedSwitch.isUserInteractionEnabled = !brandSelectedSwitch.isOn
            
            DefaultData.shared.brandsSubject
                .map { $0.count == 10 }
                .bind(to: brandSelectedSwitch.rx.isOn)
                .disposed(by: rx.disposeBag)
            
            return
        }
        
        brandSelectedSwitch.rx.isOn
            .subscribe(onNext: {
                var brands = DefaultData.shared.brandsSubject.value
                
                let code = Preferences.brand(name: name)
                
                if $0 {
                    if !brands.contains(code) { brands.append(code) }
                } else {
                    brands = brands.filter { $0 != code }
                }
                
                DefaultData.shared.brandsSubject.accept(brands)
            })
            .disposed(by: rx.disposeBag)
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
}
