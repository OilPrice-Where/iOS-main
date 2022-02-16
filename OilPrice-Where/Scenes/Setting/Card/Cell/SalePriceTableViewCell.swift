//
//  SalePriceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
import Then

final class SalePriceTableViewCell: UITableViewCell {
    //MARK: - Properties
    let brandImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let brandLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    let salePriceTextField = UITextField().then {
        $0.placeholder = "할인 가격"
        $0.keyboardType = .numberPad
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    let wonLabel = UILabel().then {
        $0.text = "원"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        var dic = DefaultData.shared.salesSubject.value
        guard let name = brandLabel.text else { return }
        
        let value = Int(salePriceTextField.text ?? "0") ?? 0
        let code = Preferences.saleBrand(name: name)
        
        guard dic[code] != value else { return }
        
        dic[code] = value
        DefaultData.shared.salesSubject.accept(dic)
    }
    
    //MARK: - Fetch Data
    func fetchData(brand: BrandInfomation) {
        brandImageView.image = brand.logo
        brandLabel.text = brand.title
        
        let dic = DefaultData.shared.salesSubject.value
        let key = Preferences.saleBrand(name: brand.title)
        
        guard let value = dic[key] else { return }
        
        salePriceTextField.text = value == 0 ? nil : "\(value)"
    }
    
    //MARK: - Configure UI
    func makeUI() {
        contentView.addSubview(brandImageView)
        contentView.addSubview(brandLabel)
        contentView.addSubview(salePriceTextField)
        contentView.addSubview(wonLabel)
        
        brandImageView.snp.makeConstraints {
            $0.left.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(30)
        }
        
        brandLabel.snp.makeConstraints {
            $0.left.equalTo(brandImageView.snp.right).offset(8)
            $0.centerY.equalToSuperview()
        }
        
        salePriceTextField.snp.makeConstraints {
            $0.left.equalTo(brandLabel.snp.right).offset(5)
            $0.centerY.equalToSuperview()
        }
        
        wonLabel.snp.makeConstraints {
            $0.left.equalTo(salePriceTextField.snp.right).offset(2)
            $0.right.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
    }
}
