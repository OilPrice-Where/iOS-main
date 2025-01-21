//
//  PriceAverageVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/17.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


//MARK: 전국 평균가
final class PriceAverageVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: PriceAverageViewModel
    
    //MARK: Background
    private let containerView = UIView().then {
        $0.alpha = .zero
        $0.layer.cornerRadius = 10.0
        $0.backgroundColor = .white
    }
    private let backgroundView = UIView().then {
        $0.alpha = .zero
        $0.backgroundColor = .black
    }
    private let titleLabel = UILabel().then {
        $0.text = "전국 평균가"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
    }
    private let closeButton = UIButton().then {
        $0.setImage(Asset.Images.close.image, for: .normal)
        $0.setImage(Asset.Images.close.image, for: .highlighted)
    }
    //MARK: 휘발유
    private let gasolineCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    private let gasolineTitleLabel = UILabel().then {
        $0.text = "휘발유"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let gasolineUpDownImageView = UIImageView()
    //MARK: 경유
    private let dieselCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    private let dieselTitleLabel = UILabel().then {
        $0.text = "경유"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let dieselUpDownImageView = UIImageView()
    //MARK: 고급 휘발유
    private let premiumCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    private let premiumTitleLabel = UILabel().then {
        $0.text = "고급유"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let premiumUpDownImageView = UIImageView()
    //MARK: LPG
    private let lpgCostLabel = UILabel().then {
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 26)
    }
    private let lpgTitleLabel = UILabel().then {
        $0.text = "LPG"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let lpgUpDownImageView = UIImageView()
    
    
    init(viewModel: PriceAverageViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) {
            self.backgroundView.alpha = 0.65
            self.containerView.alpha = 1.0
        }
    }
}

//MARK: - Binding..
private extension PriceAverageVC {
    func bindActions() {
        backgroundView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                dismiss(animated: false)
            }
            .store(in: &cancellable)
        
        closeButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                dismiss(animated: false)
            }
            .store(in: &cancellable)
        
        bindViewModel()
    }
    
    func bindViewModel() {
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher()
        ))
        
        output.updateAverageCosts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] costs in
                guard let self else { return }
                
                let priceUpIcon = Asset.Images.priceUpIcon.image
                let priceDownIcon = Asset.Images.priceDownIcon.image
                
                for cost in costs {
                    let priceTrendImage = cost.isPriceIncreased ? priceUpIcon : priceDownIcon
                    
                    switch cost.type {
                    case .gasolin:
                        gasolineCostLabel.text = cost.price
                        gasolineUpDownImageView.image = priceTrendImage
                    case .diesel:
                        dieselCostLabel.text = cost.price
                        dieselUpDownImageView.image = priceTrendImage
                    case .premium:
                        premiumCostLabel.text = cost.price
                        premiumUpDownImageView.image = priceTrendImage
                    case .lpg:
                        lpgCostLabel.text = cost.price
                        lpgUpDownImageView.image = priceTrendImage
                    }
                }
            }
            .store(in: &cancellable)
    }
}


//MARK: - Make UI
private extension PriceAverageVC {
    enum UIConstants {
        // ContainerView 사이즈
        static let containerWidth: CGFloat = 300
        static let containerHeight: CGFloat = 270

        // TitleLabel 관련 오프셋
        static let titleTopOffset: CGFloat = 32
        static let titleLeftOffset: CGFloat = 24

        // CloseButton 관련
        static let closeButtonInset: CGFloat = 12
        static let closeButtonSize: CGFloat = 40

        // Gasoline TitleLabel
        static let gasolineTitleTopOffset: CGFloat = 32
        static let gasolineTitleLeftOffset: CGFloat = 24

        // Gasoline CostLabel
        static let gasolineCostTopOffset: CGFloat = 4
        static let gasolineCostLeftOffset: CGFloat = 24

        // Gasoline UpDownImageView
        static let gasolineUpDownBottomOffset: CGFloat = -4  // gasolineCostLabel.bottom offset
        static let gasolineUpDownLeftOffset: CGFloat = 4     // gasolineCostLabel.right offset

        // Diesel UpDownImageView
        static let dieselRightInset: CGFloat = 32

        // Diesel CostLabel
        static let dieselCostRightOffset: CGFloat = -4       // dieselUpDownImageView.left offset
        // Diesel TitleLabel
        // dieselTitleLabel는 dieselCostLabel의 left와 동일

        // Premium TitleLabel
        static let premiumTitleTopOffset: CGFloat = 30   // gasolineCostLabel.bottom offset
        static let premiumTitleLeftOffset: CGFloat = 24

        // Premium CostLabel
        static let premiumCostTopOffset: CGFloat = 4     // premiumTitleLabel.bottom offset
        static let premiumCostLeftOffset: CGFloat = 24

        // Premium UpDownImageView
        static let premiumUpDownBottomOffset: CGFloat = -4  // premiumCostLabel.bottom offset
        static let premiumUpDownLeftOffset: CGFloat = 4     // premiumCostLabel.right offset

        // LPG UpDownImageView
        static let lpgRightInset: CGFloat = 32

        // LPG CostLabel
        static let lpgCostRightOffset: CGFloat = -4        // lpgUpDownImageView.left offset
    }
    
    func makeUI() {
        view.backgroundColor = .clear
        
        configureUI()
        setupConstraints()
    }
    
    func configureUI() {
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
    }
    
    func setupConstraints() {
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(UIConstants.containerWidth)
            make.height.equalTo(UIConstants.containerHeight)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(UIConstants.titleTopOffset)
            make.left.equalToSuperview().offset(UIConstants.titleLeftOffset)
        }
        closeButton.snp.makeConstraints { make in
            make.top.right.equalToSuperview().inset(UIConstants.closeButtonInset)
            make.size.equalTo(UIConstants.closeButtonSize)
        }
        gasolineTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.gasolineTitleTopOffset)
            make.left.equalToSuperview().offset(UIConstants.gasolineTitleLeftOffset)
        }
        gasolineCostLabel.snp.makeConstraints { make in
            make.top.equalTo(gasolineTitleLabel.snp.bottom).offset(UIConstants.gasolineCostTopOffset)
            make.left.equalToSuperview().offset(UIConstants.gasolineCostLeftOffset)
        }
        gasolineUpDownImageView.snp.makeConstraints { make in
            make.bottom.equalTo(gasolineCostLabel.snp.bottom).offset(UIConstants.gasolineUpDownBottomOffset)
            make.left.equalTo(gasolineCostLabel.snp.right).offset(UIConstants.gasolineUpDownLeftOffset)
        }
        dieselUpDownImageView.snp.makeConstraints { make in
            make.bottom.equalTo(gasolineUpDownImageView.snp.bottom)
            make.right.equalToSuperview().inset(UIConstants.dieselRightInset)
        }
        dieselCostLabel.snp.makeConstraints { make in
            make.bottom.equalTo(gasolineCostLabel.snp.bottom)
            make.right.equalTo(dieselUpDownImageView.snp.left).offset(UIConstants.dieselCostRightOffset)
        }
        dieselTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(gasolineTitleLabel.snp.bottom)
            make.left.equalTo(dieselCostLabel.snp.left)
        }
        premiumTitleLabel.snp.makeConstraints { make in
            make.top.equalTo(gasolineCostLabel.snp.bottom).offset(UIConstants.premiumTitleTopOffset)
            make.left.equalToSuperview().offset(UIConstants.premiumTitleLeftOffset)
        }
        premiumCostLabel.snp.makeConstraints { make in
            make.top.equalTo(premiumTitleLabel.snp.bottom).offset(UIConstants.premiumCostTopOffset)
            make.left.equalToSuperview().offset(UIConstants.premiumCostLeftOffset)
        }
        premiumUpDownImageView.snp.makeConstraints { make in
            make.bottom.equalTo(premiumCostLabel.snp.bottom).offset(UIConstants.premiumUpDownBottomOffset)
            make.left.equalTo(premiumCostLabel.snp.right).offset(UIConstants.premiumUpDownLeftOffset)
        }
        lpgUpDownImageView.snp.makeConstraints { make in
            make.bottom.equalTo(premiumUpDownImageView.snp.bottom)
            make.right.equalToSuperview().inset(UIConstants.lpgRightInset)
        }
        lpgCostLabel.snp.makeConstraints { make in
            make.bottom.equalTo(premiumCostLabel.snp.bottom)
            make.right.equalTo(lpgUpDownImageView.snp.left).offset(UIConstants.lpgCostRightOffset)
        }
        lpgTitleLabel.snp.makeConstraints { make in
            make.bottom.equalTo(premiumTitleLabel.snp.bottom)
            make.left.equalTo(lpgCostLabel.snp.left)
        }
    }
}
