//
//  SegmentedSelectionView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2026/08/19.
//  Copyright © 2026 sangwook park. All rights reserved.
//

import Then
import UIKit
import SnapKit


//MARK: 커스텀 세그먼트 (sunken 트랙 + 선택 pill)
final class SegmentedSelectionView: UIView {
    // MARK: - Properties
    private(set) var selectedIndex: Int

    private let options: [String]
    private var buttons: [UIButton] = []

    private let trackView = UIView().then {
        $0.backgroundColor = Asset.Colors.surfaceSunken.color
        $0.layer.cornerRadius = UIConstants.Radius.track
    }
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.distribution = .fillEqually
        $0.spacing = UIConstants.Spacing.gap
    }

    //MARK: - Initializer
    init(options: [String], selectedIndex: Int = 0) {
        self.options = options
        self.selectedIndex = options.indices.contains(selectedIndex) ? selectedIndex : 0

        super.init(frame: .zero)

        makeUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func buttonTapped(_ sender: UIButton) {
        guard sender.tag != selectedIndex else { return }

        selectedIndex = sender.tag
        updateSelectionAppearance()
    }
}

// MARK: - UI Configuration
private extension SegmentedSelectionView {
    enum UIConstants {
        enum Spacing {
            static let padding: CGFloat = 3
            static let gap: CGFloat = 2
        }

        enum Radius {
            static let track: CGFloat = 12
            /// pill(선택 버튼) radius = 트랙 radius - padding (design-ref/Segmented.jsx:21)
            static let pill: CGFloat = track - Spacing.padding
        }
    }

    func configureUI() {
        addSubview(trackView)
        trackView.addSubview(stackView)
    }

    func setupConstraints() {
        trackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIConstants.Spacing.padding)
        }
    }

    func makeUI() {
        configureUI()
        setupConstraints()
        configureButtons()
        updateSelectionAppearance()
    }

    // ponytail: 세그먼트가 항상 등폭(fillEqually)이라 선택 pill을 별도 UIView로 옮기는 대신
    // 선택된 버튼 자체를 surface+shadow로 스타일링한다 — 결과는 동일하고 프레임 동기화 코드가 없다.
    func configureButtons() {
        buttons = options.enumerated().map { index, title in
            let button = UIButton(type: .system)
            button.tag = index
            button.setTitle(title, for: .normal)
            button.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 14)
            button.titleLabel?.adjustsFontSizeToFitWidth = true
            button.titleLabel?.minimumScaleFactor = 0.8
            button.layer.cornerRadius = UIConstants.Radius.pill
            button.addTarget(self, action: #selector(buttonTapped(_:)), for: .touchUpInside)
            stackView.addArrangedSubview(button)
            return button
        }
    }

    func updateSelectionAppearance() {
        buttons.enumerated().forEach { index, button in
            let isSelected = index == selectedIndex

            button.backgroundColor = isSelected ? Asset.Colors.surface.color : .clear
            button.setTitleColor(isSelected ? Asset.Colors.brand.color : Asset.Colors.ink2.color, for: .normal)
            button.layer.shadowOpacity = 0
            if isSelected {
                button.addShadow(location: .bottom, color: .black, opacity: 0.08, radius: 3)
            }

            button.accessibilityTraits = isSelected ? [.button, .selected] : .button
            button.accessibilityLabel = "\(options[index]), \(index + 1)/\(options.count)"
        }
    }
}
