//
//  SelectTypeView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/16.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Then
import UIKit
import SnapKit
//MARK: 초기화면 선택 View
final class SelectTypeView: UIView {
    //MARK: - Properties
    private let oils = ["휘발유", "경유", "고급유", "LPG"]
    private let navigations = ["카카오내비", "카카오맵", "티맵", "네이버지도"]
    private let emptyView = UIView()
    private let selectOilTypeLabel = UILabel().then { // Oil Type
        $0.text = "찾으시는 기름의 종류를 선택해주세요."
        $0.textAlignment = .center
        $0.textColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    lazy var oilTypeSegmentControl = UISegmentedControl(items: oils).then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    private let selectNaviTypeLabel = UILabel().then { // Navigation Type
        $0.text = "연동할 내비게이션을 선택해주세요."
        $0.textAlignment = .center
        $0.textColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    lazy var naviTypeSegmentControl = UISegmentedControl(items: navigations).then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    let okButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.setTitle("확인", for: .highlighted)
        $0.setTitleColor(.white, for: .normal)
        $0.setTitleColor(.white, for: .highlighted)
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        viewLayoutSetUp()
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        layer.cornerRadius = 5
        okButton.layer.cornerRadius = 20
        
        backgroundColor = .white
        
        addSubview(selectOilTypeLabel)
        addSubview(oilTypeSegmentControl)
        addSubview(selectNaviTypeLabel)
        addSubview(naviTypeSegmentControl)
        addSubview(okButton)
        addSubview(emptyView)
        
        selectOilTypeLabel.snp.makeConstraints {
            $0.left.top.right.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        oilTypeSegmentControl.snp.makeConstraints {
            $0.top.equalTo(selectOilTypeLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(30)
        }
        selectNaviTypeLabel.snp.makeConstraints {
            $0.top.equalTo(oilTypeSegmentControl.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(20)
        }
        naviTypeSegmentControl.snp.makeConstraints {
            $0.top.equalTo(selectNaviTypeLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(30)
        }
        okButton.snp.makeConstraints {
            $0.top.equalTo(naviTypeSegmentControl.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(40)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(okButton.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
    }
    
    private func viewLayoutSetUp() {
        let font = FontFamily.NanumSquareRound.regular.font(size: 15)
        
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                              .foregroundColor: UIColor.black]
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                                .foregroundColor: UIColor.white]
        
        oilTypeSegmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
        oilTypeSegmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
        naviTypeSegmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
        naviTypeSegmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
    }
}

