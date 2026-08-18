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

    private let logoImageView = UIImageView().then {
        $0.image = UIImage(
            systemName: "fuelpump.fill",
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 26, weight: .bold)
        )
        $0.tintColor = .white
        $0.contentMode = .center
        $0.backgroundColor = Asset.Colors.brand.color
        $0.layer.cornerRadius = UIConstants.Radius.logo
        $0.clipsToBounds = true
    }
    private let titleLabel = UILabel().then {
        $0.text = "몇 가지만 알려주세요"
        $0.textColor = Asset.Colors.ink.color
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
        $0.numberOfLines = 0
    }
    private let subtitleLabel = UILabel().then {
        $0.text = "가까운 곳에서 가장 싼 주유소를 찾아드릴게요."
        $0.textColor = Asset.Colors.ink2.color
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.numberOfLines = 0
    }
    private lazy var headerStackView = UIStackView(arrangedSubviews: [logoImageView, titleLabel, subtitleLabel]).then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.setCustomSpacing(UIConstants.Spacing.logoToTitle, after: logoImageView)
        $0.setCustomSpacing(UIConstants.Spacing.titleToSubtitle, after: titleLabel)
    }

    private let sectionLabel = UILabel().then {
        $0.text = "기름 종류를 선택해주세요"
        $0.textColor = Asset.Colors.brand.color
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    private lazy var fuelSegmentedView = SegmentedSelectionView(options: fuelTypes.map { $0.displayName })
    private let navigationSectionLabel = UILabel().then {
        $0.text = "연동할 내비게이션을 선택해주세요"
        $0.textColor = Asset.Colors.brand.color
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    private lazy var navigationSegmentedView = SegmentedSelectionView(options: navigationTypes.map { $0.displayName })
    private lazy var cardStackView = UIStackView(arrangedSubviews: [sectionLabel, fuelSegmentedView, navigationSectionLabel, navigationSegmentedView]).then {
        $0.axis = .vertical
        $0.spacing = UIConstants.Spacing.sectionLabelToSegment
        $0.setCustomSpacing(UIConstants.Spacing.sectionToSection, after: fuelSegmentedView)
    }
    private let cardView = UIView().then {
        $0.backgroundColor = Asset.Colors.surface.color
        $0.layer.cornerRadius = UIConstants.Radius.card
    }

    private let startButton = UIButton().then {
        $0.setTitle("시작하기", for: .normal)
        $0.setTitleColor(.white, for: .normal)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 18)
        $0.backgroundColor = Asset.Colors.brand.color
        $0.layer.cornerRadius = UIConstants.Radius.button
    }

    //MARK: - Initializer
    init() {
        super.init(frame: .zero)

        makeUI()
        configureStartButton()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func configureStartButton() {
        startButton.addTarget(self, action: #selector(startButtonTapped), for: .touchUpInside)
    }

    @objc
    private func startButtonTapped() {
        let result: InitialSettingsViewModel.SelectionResult = .init(
            fuel: fuelTypes[fuelSegmentedView.selectedIndex],
            navigation: navigationTypes[navigationSegmentedView.selectedIndex]
        )
        delegate?.initialSettingsView(self, didSelect: result)
    }
}

// MARK: - UI Configuration
private extension InitialSettingsView {
    enum UIConstants {
        enum Spacing {
            static let logoToTitle: CGFloat = 18
            static let titleToSubtitle: CGFloat = 8
            static let headerToCard: CGFloat = 24
            static let cardToButton: CGFloat = 24
            static let sectionLabelToSegment: CGFloat = 10
            static let sectionToSection: CGFloat = 22
        }

        enum Insets {
            static let cardVertical: CGFloat = 22
            static let cardHorizontal: CGFloat = 20
        }

        enum Sizes {
            static let logo: CGFloat = 56
            static let segment: CGFloat = 44
            static let button: CGFloat = 52
        }

        enum Radius {
            static let logo: CGFloat = 16
            static let card: CGFloat = 24
            static let button: CGFloat = 12
        }
    }

    func configureUI() {
        addSubview(headerStackView)
        addSubview(cardView)
        cardView.addSubview(cardStackView)
        addSubview(startButton)
    }

    func setupConstraints() {
        logoImageView.snp.makeConstraints { make in
            make.width.height.equalTo(UIConstants.Sizes.logo)
        }

        headerStackView.snp.makeConstraints { make in
            make.top.left.right.equalToSuperview()
        }

        cardView.snp.makeConstraints { make in
            make.top.equalTo(headerStackView.snp.bottom).offset(UIConstants.Spacing.headerToCard)
            make.left.right.equalToSuperview()
        }

        cardStackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(UIConstants.Insets.cardVertical)
            make.left.right.equalToSuperview().inset(UIConstants.Insets.cardHorizontal)
        }

        fuelSegmentedView.snp.makeConstraints { make in
            make.height.equalTo(UIConstants.Sizes.segment)
        }

        navigationSegmentedView.snp.makeConstraints { make in
            make.height.equalTo(UIConstants.Sizes.segment)
        }

        startButton.snp.makeConstraints { make in
            make.top.equalTo(cardView.snp.bottom).offset(UIConstants.Spacing.cardToButton)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(UIConstants.Sizes.button)
        }
    }

    func makeUI() {
        backgroundColor = .clear

        configureUI()
        setupConstraints()
        addCardShadow()
    }

    func addCardShadow() {
        cardView.addShadow(location: .bottom, color: .black, opacity: 0.08, radius: 3)
    }
}
