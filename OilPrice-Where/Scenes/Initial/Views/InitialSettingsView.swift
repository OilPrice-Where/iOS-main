//
//  InitialSettingsView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/16.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Then
import UIKit
import SnapKit


protocol InitialSettingsViewDelegate: AnyObject {
    func initialSettingsView(_ view: InitialSettingsView, didSelect selection: InitialSettingsViewModel.SelectionResult)
}


//MARK: 초기화면 선택 View
final class InitialSettingsView: UIView {
    // MARK: - Properties
    weak var delegate: InitialSettingsViewDelegate?
    
    private let fuelTypes = FuelType.allCases
    private let navigationTypes = SearchNavigation.allCases
    
    private let selectOilTypeLabel = UILabel().then {
        $0.text = "찾으시는 기름의 종류를 선택해주세요."
        $0.textAlignment = .center
        $0.textColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    private let fuelTypeSegmentControl = UISegmentedControl().then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    private let selectNaviTypeLabel = UILabel().then {
        $0.text = "연동할 내비게이션을 선택해주세요."
        $0.textAlignment = .center
        $0.textColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    private let naviTypeSegmentControl = UISegmentedControl().then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    private let completeButton = UIButton().then {
        $0.setTitle("확인", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = 20
    }
    
    /// 하단 여백을 위한 빈 뷰
    private let spacerView = UIView()
    
    //MARK: - Initializer
    init() {
        super.init(frame: .zero)
        
        makeUI()
        configureCompleteButton()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureCompleteButton() {
        completeButton.addTarget(self, action: #selector(completeButtonTapped), for: .touchUpInside)
    }
    
    @objc
    private func completeButtonTapped() {
        let result: InitialSettingsViewModel.SelectionResult = .init(
            fuel: fuelTypes[fuelTypeSegmentControl.selectedSegmentIndex],
            navigation: navigationTypes[naviTypeSegmentControl.selectedSegmentIndex]
        )
        delegate?.initialSettingsView(self, didSelect: result)
    }
}

// MARK: - UI Configuration
private extension InitialSettingsView {
    enum UIConstants {
        enum Insets {
            static let general: CGFloat = 16
        }
        
        enum Heights {
            static let label: CGFloat = 20
            static let segment: CGFloat = 30
            static let button: CGFloat = 40
        }
        
        enum Offsets {
            static let labelToSegment: CGFloat = 12
            static let segmentToLabel: CGFloat = 16
            static let segmentToButton: CGFloat = 16
            static let buttonToBottom: CGFloat = 16
        }
    }
    
    func configureUI() {
        addSubview(selectOilTypeLabel)
        addSubview(fuelTypeSegmentControl)
        addSubview(selectNaviTypeLabel)
        addSubview(naviTypeSegmentControl)
        addSubview(completeButton)
        addSubview(spacerView)
    }
    
    func setupConstraints() {
        selectOilTypeLabel.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview().inset(UIConstants.Insets.general)
            make.height.equalTo(UIConstants.Heights.label)
        }
        
        fuelTypeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(selectOilTypeLabel.snp.bottom).offset(UIConstants.Offsets.labelToSegment)
            make.left.right.equalToSuperview().inset(UIConstants.Insets.general)
            make.height.equalTo(UIConstants.Heights.segment)
        }
        
        selectNaviTypeLabel.snp.makeConstraints { make in
            make.top.equalTo(fuelTypeSegmentControl.snp.bottom).offset(UIConstants.Offsets.segmentToLabel)
            make.left.right.equalToSuperview().inset(UIConstants.Insets.general)
            make.height.equalTo(UIConstants.Heights.label)
        }
        
        naviTypeSegmentControl.snp.makeConstraints { make in
            make.top.equalTo(selectNaviTypeLabel.snp.bottom).offset(UIConstants.Offsets.labelToSegment)
            make.left.right.equalToSuperview().inset(UIConstants.Insets.general)
            make.height.equalTo(UIConstants.Heights.segment)
        }
        
        completeButton.snp.makeConstraints { make in
            make.top.equalTo(naviTypeSegmentControl.snp.bottom).offset(UIConstants.Offsets.segmentToButton)
            make.left.right.equalToSuperview().inset(UIConstants.Insets.general)
            make.height.equalTo(UIConstants.Heights.button)
        }
        
        spacerView.snp.makeConstraints { make in
            make.top.equalTo(completeButton.snp.bottom)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-UIConstants.Offsets.buttonToBottom)
        }
    }
    
    func makeUI() {
        backgroundColor = .white
        layer.cornerRadius = 5
        
        configureUI()
        setupConstraints()
        setupSegmentControlStyles()
        configureFuelTypeSegmentControl()
        configureNaviTypeSegmentControl()
    }
    
    func setupSegmentControlStyles() {
        let font = FontFamily.NanumSquareRound.regular.font(size: 15)
        let normalAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.black]
        let selectedAttributes: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.white]
        
        fuelTypeSegmentControl.setTitleTextAttributes(normalAttributes, for: .normal)
        fuelTypeSegmentControl.setTitleTextAttributes(selectedAttributes, for: .selected)
        naviTypeSegmentControl.setTitleTextAttributes(normalAttributes, for: .normal)
        naviTypeSegmentControl.setTitleTextAttributes(selectedAttributes, for: .selected)
    }
    
    func configureFuelTypeSegmentControl() {
        // 기존 세그먼트 모두 제거
        fuelTypeSegmentControl.removeAllSegments()
        
        // 배열의 각 요소를 세그먼트로 추가
        for (index, fuelType) in fuelTypes.enumerated() {
            fuelTypeSegmentControl.insertSegment(withTitle: fuelType.displayName, at: index, animated: false)
        }
        
        // 기본 선택 인덱스 설정 (옵션)
        if !fuelTypes.isEmpty {
            fuelTypeSegmentControl.selectedSegmentIndex = 0
        }
    }
    
    func configureNaviTypeSegmentControl() {
        // 기존 세그먼트 모두 제거
        naviTypeSegmentControl.removeAllSegments()
        
        // 배열의 각 요소를 세그먼트로 추가
        for (index, navigationType) in navigationTypes.enumerated() {
            naviTypeSegmentControl.insertSegment(withTitle: navigationType.displayName, at: index, animated: false)
        }
        
        // 기본 선택 인덱스 설정 (옵션)
        if !navigationTypes.isEmpty {
            naviTypeSegmentControl.selectedSegmentIndex = 0
        }
    }
}
