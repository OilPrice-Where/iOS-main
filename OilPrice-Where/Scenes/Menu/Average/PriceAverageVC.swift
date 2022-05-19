//
//  PriceAverageVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/17.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import Firebase

//MARK: 전국 평균가
final class PriceAverageVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    let firebaseUtility = FirebaseUtility()
    // Background
    let containerView = UIView().then {
        $0.alpha = 0.0
        $0.layer.cornerRadius = 10.0
        $0.backgroundColor = .white
    }
    let backgroundView = UIView().then {
        $0.alpha = 0.0
        $0.backgroundColor = .black
    }
    let titleLabel = UILabel().then {
        $0.text = "전국 평균가"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
    }
    let closeButton = UIButton().then {
        $0.setImage(Asset.Images.close.image, for: .normal)
        $0.setImage(Asset.Images.close.image, for: .highlighted)
    }
    // 휘발유
    let gasolineCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    let gasolineTitleLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    let gasolineUpDownImageView = UIImageView()
    // 경유
    let dieselCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    let dieselTitleLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    let dieselUpDownImageView = UIImageView()
    // 고급 휘발유
    let premiumCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    let premiumTitleLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    let premiumUpDownImageView = UIImageView()
    // LPG
    let lpgCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    let lpgTitleLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    let lpgUpDownImageView = UIImageView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchAverageCosts()
        makeUI()
        rxBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.backgroundView.alpha = 0.65
            self?.containerView.alpha = 1.0
        }
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .clear
        
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(closeButton)
        containerView.addSubview(gasolineCostLabel)
        containerView.addSubview(gasolineTitleLabel)
        containerView.addSubview(gasolineUpDownImageView)
        containerView.addSubview(dieselCostLabel)
        containerView.addSubview(dieselTitleLabel)
        containerView.addSubview(dieselUpDownImageView)
        containerView.addSubview(premiumCostLabel)
        containerView.addSubview(premiumTitleLabel)
        containerView.addSubview(premiumUpDownImageView)
        containerView.addSubview(lpgCostLabel)
        containerView.addSubview(lpgTitleLabel)
        containerView.addSubview(lpgUpDownImageView)
        
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
            $0.height.equalTo(270)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            $0.left.equalToSuperview().offset(24)
        }
        closeButton.snp.makeConstraints {
            $0.top.right.equalToSuperview().inset(12)
            $0.size.equalTo(40)
        }
        gasolineTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(32)
            $0.left.equalToSuperview().offset(24)
        }
        gasolineCostLabel.snp.makeConstraints {
            $0.top.equalTo(gasolineTitleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        gasolineUpDownImageView.snp.makeConstraints {
            $0.bottom.equalTo(gasolineCostLabel.snp.bottom).offset(-4)
            $0.left.equalTo(gasolineCostLabel.snp.right).offset(4)
        }
        dieselUpDownImageView.snp.makeConstraints {
            $0.bottom.equalTo(gasolineUpDownImageView.snp.bottom)
            $0.right.equalToSuperview().inset(32)
        }
        dieselCostLabel.snp.makeConstraints {
            $0.bottom.equalTo(gasolineCostLabel.snp.bottom)
            $0.right.equalTo(dieselUpDownImageView.snp.left).offset(-4)
        }
        dieselTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(gasolineTitleLabel.snp.bottom)
            $0.left.equalTo(dieselCostLabel.snp.left)
        }
        premiumTitleLabel.snp.makeConstraints {
            $0.top.equalTo(gasolineCostLabel.snp.bottom).offset(30)
            $0.left.equalToSuperview().offset(24)
        }
        premiumCostLabel.snp.makeConstraints {
            $0.top.equalTo(premiumTitleLabel.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(24)
        }
        premiumUpDownImageView.snp.makeConstraints {
            $0.bottom.equalTo(premiumCostLabel.snp.bottom).offset(-4)
            $0.left.equalTo(premiumCostLabel.snp.right).offset(4)
        }
        lpgUpDownImageView.snp.makeConstraints {
            $0.bottom.equalTo(premiumUpDownImageView.snp.bottom)
            $0.right.equalToSuperview().inset(32)
        }
        lpgCostLabel.snp.makeConstraints {
            $0.bottom.equalTo(premiumCostLabel.snp.bottom)
            $0.right.equalTo(lpgUpDownImageView.snp.left).offset(-4)
        }
        lpgTitleLabel.snp.makeConstraints {
            $0.bottom.equalTo(premiumTitleLabel.snp.bottom)
            $0.left.equalTo(lpgCostLabel.snp.left)
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        backgroundView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: bag)
        
        closeButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: bag)
    }
    
    // HeaderView 설정
    func fetchAverageCosts() {
        firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
            self.gasolineTitleLabel.text = "휘발유"
            self.gasolineCostLabel.text = data["price"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.gasolineUpDownImageView.image = Asset.Images.priceUpIcon.image
            } else {
                self.gasolineUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
        }
        firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
            self.dieselTitleLabel.text = "경유"
            self.dieselCostLabel.text = data["price"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.dieselUpDownImageView.image = Asset.Images.priceUpIcon.image
            } else {
                self.dieselUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
    
        }
        firebaseUtility.getAverageCost(productName: "premiumCost") { (data) in
            self.premiumTitleLabel.text = "고급유"
            self.premiumCostLabel.text = data["price"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.premiumUpDownImageView.image = Asset.Images.priceUpIcon.image
            } else {
                self.premiumUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
        }
        firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
            self.lpgTitleLabel.text = "LPG"
            self.lpgCostLabel.text = data["price"] as? String ?? ""
            if data["difference"] as? Bool ?? true {
                self.lpgUpDownImageView.image = Asset.Images.priceUpIcon.image
            } else {
                self.lpgUpDownImageView.image = Asset.Images.priceDownIcon.image
            }
        }
    }
}
