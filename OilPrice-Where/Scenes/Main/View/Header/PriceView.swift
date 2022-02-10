//
//  PriceView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class PriceView: UIView {
    //MARK: - Properties
    let firebaseUtility = FirebaseUtility()
    
    // 전국 평균가
    let titleLabel = UILabel().then {
        $0.text = "전국 평균가"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    // 휘발유 가격
    let gasolineCostLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 33)
    }
    // 휘발유 타이틀
    let gasolineTitleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    // 가격 오름 내림 이미지
    let gasolineUpDownImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    // 경유 가격
    let dieselCostLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 20)
    }
    // 경유 타이틀
    let dieselTitleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 11)
    }
    // 가격 오름 내림 이미지
    let dieselUpDownImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    // LPG 가격
    let lpgCostLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 20)
    }
    // LPG 타이틀
    let lpgTitleLabel = UILabel().then {
        $0.textColor = .lightGray
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 11)
    }
    // 가격 오름 내림 이미지
    let lpgUpDownImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        backgroundColor = .white
        layer.cornerRadius = 10
        
        addSubview(titleLabel)
        addSubview(gasolineCostLabel)
        addSubview(gasolineTitleLabel)
        addSubview(gasolineUpDownImageView)
        addSubview(dieselCostLabel)
        addSubview(dieselTitleLabel)
        addSubview(dieselUpDownImageView)
        addSubview(lpgCostLabel)
        addSubview(lpgTitleLabel)
        addSubview(lpgUpDownImageView)
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.greaterThanOrEqualToSuperview().offset(25)
            $0.width.equalTo(77)
            $0.height.equalTo(18)
        }
        
        gasolineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(22)
            $0.width.equalTo(39)
            $0.height.equalTo(16)
        }
        
        gasolineCostLabel.snp.makeConstraints {
            $0.top.equalTo(gasolineTitleLabel.snp.bottom).offset(1)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(37)
        }
        
        gasolineUpDownImageView.snp.makeConstraints {
            $0.centerY.equalTo(gasolineCostLabel)
            $0.left.equalTo(gasolineCostLabel.snp.right).offset(5)
            $0.size.equalTo(15)
        }
        
        dieselTitleLabel.snp.makeConstraints {
            $0.top.equalTo(gasolineCostLabel.snp.bottom).offset(6)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(21)
            $0.height.equalTo(13)
        }
        
        dieselCostLabel.snp.makeConstraints {
            $0.top.equalTo(dieselTitleLabel.snp.bottom).offset(1)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(23)
        }
        
        dieselUpDownImageView.snp.makeConstraints {
            $0.centerY.equalTo(dieselCostLabel)
            $0.left.equalTo(dieselCostLabel.snp.right).offset(5)
            $0.size.equalTo(10)
        }
        
        lpgTitleLabel.snp.makeConstraints {
            $0.top.equalTo(gasolineCostLabel.snp.bottom).offset(6)
            $0.left.equalTo(dieselUpDownImageView.snp.right).offset(12)
            $0.width.equalTo(21)
            $0.height.equalTo(13)
        }
        
        lpgCostLabel.snp.makeConstraints {
            $0.top.equalTo(lpgTitleLabel.snp.bottom).offset(1)
            $0.left.equalTo(dieselUpDownImageView.snp.right).offset(10)
            $0.height.equalTo(23)
        }
        
        lpgUpDownImageView.snp.makeConstraints {
            $0.centerY.equalTo(lpgCostLabel)
            $0.left.equalTo(lpgCostLabel.snp.right).offset(5)
            $0.size.equalTo(10)
        }
    }
    
    // HeaderView 설정
    func fetchAverageCosts() {
        firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
            self.gasolineCostLabel.text = data["price"] as? String ?? ""
            self.gasolineTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.gasolineUpDownImageView.image = Asset.Images.priceUpIcon.image
            }else {
                self.gasolineUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
        }
        firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
            self.dieselCostLabel.text = data["price"] as? String ?? ""
            self.dieselTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.dieselUpDownImageView.image = Asset.Images.priceUpIcon.image
            }else {
                self.dieselUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
            
        }
        firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
            self.lpgCostLabel.text = data["price"] as? String ?? ""
            self.lpgTitleLabel.text = data["productName"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.lpgUpDownImageView.image = Asset.Images.priceUpIcon.image
            } else {
                self.lpgUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
        }
    }
}
