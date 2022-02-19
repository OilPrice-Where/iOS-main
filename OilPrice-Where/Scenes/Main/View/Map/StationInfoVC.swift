//
//  StationInfoVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

//MARK: Station Info VC
final class StationInfoVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    var station: InformationGasStaion?
    var stationInfoView = StationInfoView()
    var guideView = UIView().then {
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 1.3
    }
    var lineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    var titleByPriceLabel = UILabel().then {
        $0.text = "주유소 상세정보"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    var addressKeyLabel = UILabel().then {
        $0.text = "주소"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var phoneNumberKeyLabel = UILabel().then {
        $0.text = "전화"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var quailtyKeyLabel = UILabel().then {
        $0.text = "품질인증주유소 여부"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var addressValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
    }
    var phoneNumberValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
    }
    var quailtyValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 12)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .white
        view.addSubview(stationInfoView)
        view.addSubview(guideView)
        view.addSubview(lineView)
        view.addSubview(titleByPriceLabel)
        view.addSubview(addressKeyLabel)
        view.addSubview(phoneNumberKeyLabel)
        view.addSubview(quailtyKeyLabel)
        view.addSubview(addressValueLabel)
        view.addSubview(phoneNumberValueLabel)
        view.addSubview(quailtyValueLabel)
        
        guideView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(30)
            $0.height.equalTo(2.6)
        }
        
        stationInfoView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(98)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(stationInfoView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(5)
        }
        titleByPriceLabel.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview()
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(titleByPriceLabel.snp.bottom).offset(14)
            $0.left.equalToSuperview().offset(14)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        quailtyKeyLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        addressValueLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        phoneNumberValueLabel.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        quailtyValueLabel.snp.makeConstraints {
            $0.top.equalTo(quailtyKeyLabel.snp.top)
            $0.left.equalTo(quailtyKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        
    }
}
