//
//  CardBenefitTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/08/14.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa

class CardBenefitTableViewCell: UITableViewCell {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let items = ["L당 할인", "결제일 %할인"]
    private let saleTypeLabel = UILabel().then {
        $0.text = "혜택 타입"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private lazy var segmentControl = UISegmentedControl(items: items).then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    private let salePriceLabel = UILabel().then {
        $0.text = "할인 금액"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let salePriceValueLabel = UILabel().then {
        $0.text = "0원"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10.0
        $0.layer.masksToBounds = true
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 20)
    }
    private let stepper = UIStepper().then {
        $0.stepValue = 1
        $0.minimumValue = 0
        $0.maximumValue = 200
        $0.wraps = true
    }
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func makeUI() {
        let font = FontFamily.NanumSquareRound.regular.font(size: 15)
        
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                              .foregroundColor: UIColor.black]
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                                .foregroundColor: UIColor.white]
        
        segmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
        segmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
        
        contentView.addSubview(saleTypeLabel)
        contentView.addSubview(segmentControl)
        contentView.addSubview(salePriceLabel)
        contentView.addSubview(salePriceValueLabel)
        contentView.addSubview(stepper)
        
        saleTypeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.left.equalToSuperview().offset(16)
        }
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(saleTypeLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        salePriceLabel.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(16)
        }
        stepper.snp.makeConstraints {
            $0.top.equalTo(salePriceLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        salePriceValueLabel.snp.makeConstraints {
            $0.top.equalTo(salePriceLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(stepper.snp.left)
            $0.height.equalTo(stepper)
        }
    }
    
    func rxBind() {
        segmentControl
            .selectedSegmentIndexPublisher
            .map { $0 == 0 ? true : false }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isSelect in
                guard let owner = self else { return }
                
                owner.stepper.value = 0.0
                owner.stepper.stepValue = isSelect ? 1.0 : 0.1
                owner.stepper.maximumValue = isSelect ? 500.0 : 50.0
                owner.salePriceValueLabel.text = "0\(isSelect ? "원" : "%")"
            }
            .store(in: &cancelBag)
        
        stepper
            .valuePublisher
            .map { self.segmentControl.selectedSegmentIndex == 0 ? "\(Int($0))원" : String(format: "%.1f%%", $0) }
            .assign(to: \.text, on: salePriceValueLabel)
            .store(in: &cancelBag)
    }
}
