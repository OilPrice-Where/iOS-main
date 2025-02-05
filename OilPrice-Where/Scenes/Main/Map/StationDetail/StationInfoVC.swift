//
//  StationInfoVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import Toast
import SnapKit


extension StationInfoVC {
    func configure(station: GasStationSummary) {
        stationInfoView.configure(
            fuelType: viewModel.currentFuelType(),
            station: station
        )
    }
}


//MARK: MapView에 주유소 정보 VC
final class StationInfoVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: StationInfoViewModel
    
    private let requestStationDetailPublisher = PassthroughSubject<String, Never>()
    
    private let stationInfoView = StationInfoView()
    private let guideView = UIView().then {
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = UIConstants.GuideView.cornerRadius
    }
    private let topLineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    private let titleByStationDetailLabel = UILabel().then {
        $0.text = UIConstants.TitleByStationDetailLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.TitleByStationDetailLabel.font
    }
    private let washImageView = UIImageView().then {
        $0.image = UIConstants.WashImageView.image
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
    }
    private let repairImageView = UIImageView().then {
        $0.image = UIConstants.RepairImageView.image
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
    }
    private let convenienceImageView = UIImageView().then {
        $0.image = UIConstants.ConvenienceImageView.image
        $0.contentMode = .scaleAspectFit
        $0.tintColor = .lightGray
    }
    private let addressKeyLabel = UILabel().then {
        $0.text = UIConstants.AddressKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.AddressKeyLabel.font
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let phoneNumberKeyLabel = UILabel().then {
        $0.text = UIConstants.PhoneNumberKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.PhoneNumberKeyLabel.font
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let addressValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    private let phoneNumberValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    private let bottomLineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    private let titleByPriceLabel = UILabel().then {
        $0.text = UIConstants.TitleByPriceLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.TitleByPriceLabel.font
    }
    private let oilKeyLabel = UILabel().then {
        $0.text = UIConstants.FuelKey.displayName(type: .gasoline)
        $0.textAlignment = .left
        $0.font = UIConstants.FuelKey.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let highOilKeyLabel = UILabel().then {
        $0.text = UIConstants.FuelKey.displayName(type: .premiumGasoline)
        $0.textAlignment = .left
        $0.font = UIConstants.FuelKey.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let diselKeyLabel = UILabel().then {
        $0.text = UIConstants.FuelKey.displayName(type: .diesel)
        $0.textAlignment = .left
        $0.font = UIConstants.FuelKey.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let lpgKeyLabel = UILabel().then {
        $0.text = UIConstants.FuelKey.displayName(type: .lpg)
        $0.textAlignment = .left
        $0.font = UIConstants.FuelKey.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let oilValueLabel = UILabel().then {
        $0.text = UIConstants.FuelValue.text
        $0.textAlignment = .right
        $0.font = UIConstants.FuelValue.font
    }
    private let highOilValueLabel = UILabel().then {
        $0.text = UIConstants.FuelValue.text
        $0.textAlignment = .right
        $0.font = UIConstants.FuelValue.font
    }
    private let diselValueLabel = UILabel().then {
        $0.text = UIConstants.FuelValue.text
        $0.textAlignment = .right
        $0.font = UIConstants.FuelValue.font
    }
    private let lpgValueLabel = UILabel().then {
        $0.text = UIConstants.FuelValue.text
        $0.textAlignment = .right
        $0.font = UIConstants.FuelValue.font
    }
    
    
    //MARK: - Life Cycle
    init(viewModel: StationInfoViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindActions()
    }
    
    func requestStationDetail(id: String?) {
        guard let id, id.isNotEmpty else {
            return
        }
        requestStationDetailPublisher.send(id)
    }
}


//MARK: - Binding..
private extension StationInfoVC {
    func bindActions() {
        // 주소 복사 버튼 탭
        let addressButtonTapped = addressValueButton.tapPublisher
            .map { [weak self] in
                self?.addressValueButton.titleLabel?.text
            }
            .eraseToAnyPublisher()
        // 전화연결 버튼 탭
        let phoneNumberButton = phoneNumberValueButton.tapPublisher
            .compactMap { [weak self] _ -> String? in
                guard let phoneNumber = self?.phoneNumberValueButton.titleLabel?.text,
                      phoneNumber.isNotEmpty else {
                    return nil
                }
                return "tel:" + phoneNumber
            }
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: .init(
            requestStationDetail: requestStationDetailPublisher.eraseToAnyPublisher(),
            addressButtonTapped: addressButtonTapped,
            phoneNumberButtonTapped: phoneNumberButton
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: StationInfoViewModel.Output) {
        // openURL
        output.openURL
            .receive(on: DispatchQueue.main)
            .sink { url in
                guard UIApplication.shared.canOpenURL(url) else {
                    return
                }
                UIApplication.shared.open(url)
            }
            .store(in: &cancellable)
        // washImageView
        output.updateStationDetail
            .map { $0.hasCarWash ? Asset.Colors.mainColor.color : .lightGray }
            .receive(on: DispatchQueue.main)
            .assign(to: \.tintColor, on: washImageView)
            .store(in: &cancellable)
        // repairImageView
        output.updateStationDetail
            .map { $0.hasRepairShop ? Asset.Colors.mainColor.color : .lightGray }
            .receive(on: DispatchQueue.main)
            .assign(to: \.tintColor, on: repairImageView)
            .store(in: &cancellable)
        // convenienceImageView
        output.updateStationDetail
            .map { $0.hasConvenienceStore ? Asset.Colors.mainColor.color : .lightGray }
            .receive(on: DispatchQueue.main)
            .assign(to: \.tintColor, on: convenienceImageView)
            .store(in: &cancellable)
        // addressValueButton
        output.updateStationDetail
            .map { $0.address }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
                let underlineAttributedString = NSAttributedString(string: address, attributes: underlineAttribute)
                self?.addressValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
            }
            .store(in: &cancellable)
        // phoneNumberValueButton
        output.updateStationDetail
            .map { $0.phoneNumber }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phoneNumber in
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
                let underlineAttributedString = NSAttributedString(string: phoneNumber, attributes: underlineAttribute)
                self?.phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
            }
            .store(in: &cancellable)
        // prices
        output.updateStationDetail
            .map { $0.prices }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fuelPrices in
                for fuelPrice in fuelPrices {
                    switch fuelPrice.fuelType {
                    case .gasoline:
                        self?.oilValueLabel.text = fuelPrice.price.decimalNumber
                    case .premiumGasoline:
                        self?.highOilValueLabel.text = fuelPrice.price.decimalNumber
                    case .diesel:
                        self?.diselValueLabel.text = fuelPrice.price.decimalNumber
                    case .lpg:
                        self?.lpgValueLabel.text = fuelPrice.price.decimalNumber
                    }
                }
            }
            .store(in: &cancellable)
    }
}


//MARK: - Set UI
private extension StationInfoVC {
    enum UIConstants {
        enum StationInfoView {
            static let topOffset: CGFloat = 10
            static let height: CGFloat = 88
        }
        
        enum GuideView {
            static let cornerRadius: CGFloat = 1.3
            
            static let topOffset: CGFloat = 10
            static let width: CGFloat = 30
            static let height: CGFloat = 2.6
        }
        
        enum TopLineView {
            static let topOffset: CGFloat = 10
            static let height: CGFloat = 5
        }
        
        enum TitleByStationDetailLabel {
            static let text: String = "주유소 상세정보"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let topOffset: CGFloat = 16
            static let leftOffset: CGFloat = 14
        }
        
        enum WashImageView {
            static let image: UIImage = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -4
            static let size: CGFloat = 20
        }
        
        enum RepairImageView {
            static let image: UIImage = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -4
            static let size: CGFloat = 20
        }
        
        enum ConvenienceImageView {
            static let image: UIImage = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -16
            static let size: CGFloat = 20
        }
        
        enum AddressKeyLabel {
            static let text: String = "주소"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let topOffset: CGFloat = 16
            static let leftOffset: CGFloat = 14
        }
        
        enum PhoneNumberKeyLabel {
            static let text: String = "전화"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 14
        }
        
        enum BottomLineView {
            static let topOffset: CGFloat = 10
            static let height: CGFloat = 5
        }
        
        enum TitleByPriceLabel {
            static let text: String = "가격 정보"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let topOffset: CGFloat = 16
            static let leftOffset: CGFloat = 14
        }
        
        enum FuelKey {
            static let text: String = "휘발유"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 14)
            
            static let topOffset: CGFloat = 10
            static let leftOffset: CGFloat = 14
            
            static func displayName(type: FuelType) -> String {
                return type.displayName
            }
        }
        
        enum FuelValue {
            static let text: String = "가격정보 없음"
            static let font: UIFont = FontFamily.NanumSquareRound.extraBold.font(size: 14)
            
            static let leftOffset: CGFloat = 5
            static let rightOffset: CGFloat = -14
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(stationInfoView)
        view.addSubview(guideView)
        view.addSubview(topLineView)
        view.addSubview(titleByStationDetailLabel)
        view.addSubview(washImageView)
        view.addSubview(repairImageView)
        view.addSubview(convenienceImageView)
        view.addSubview(addressKeyLabel)
        view.addSubview(phoneNumberKeyLabel)
        view.addSubview(addressValueButton)
        view.addSubview(phoneNumberValueButton)
        view.addSubview(bottomLineView)
        view.addSubview(titleByPriceLabel)
        view.addSubview(oilKeyLabel)
        view.addSubview(highOilKeyLabel)
        view.addSubview(diselKeyLabel)
        view.addSubview(lpgKeyLabel)
        view.addSubview(oilValueLabel)
        view.addSubview(highOilValueLabel)
        view.addSubview(diselValueLabel)
        view.addSubview(lpgValueLabel)
    }
    
    func setConstraints() {
        guideView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.GuideView.topOffset)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIConstants.GuideView.width)
            $0.height.equalTo(UIConstants.GuideView.height)
        }
        stationInfoView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.StationInfoView.topOffset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIConstants.StationInfoView.height)
        }
        topLineView.snp.makeConstraints {
            $0.top.equalTo(stationInfoView.snp.bottom).offset(UIConstants.TopLineView.topOffset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIConstants.TopLineView.height)
        }
        titleByStationDetailLabel.snp.makeConstraints {
            $0.top.equalTo(topLineView.snp.bottom).offset(UIConstants.TitleByStationDetailLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.TitleByStationDetailLabel.leftOffset)
            $0.right.equalToSuperview()
        }
        convenienceImageView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(UIConstants.ConvenienceImageView.rightOffset)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(UIConstants.ConvenienceImageView.size)
        }
        repairImageView.snp.makeConstraints {
            $0.right.equalTo(convenienceImageView.snp.left).offset(UIConstants.RepairImageView.rightOffset)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(UIConstants.RepairImageView.size)
        }
        washImageView.snp.makeConstraints {
            $0.right.equalTo(repairImageView.snp.left).offset(UIConstants.WashImageView.rightOffset)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(UIConstants.WashImageView.size)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(titleByStationDetailLabel.snp.bottom).offset(UIConstants.AddressKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.AddressKeyLabel.leftOffset)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(UIConstants.PhoneNumberKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.PhoneNumberKeyLabel.leftOffset)
        }
        addressValueButton.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        phoneNumberValueButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        bottomLineView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberValueButton.snp.bottom).offset(UIConstants.BottomLineView.topOffset)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(UIConstants.BottomLineView.height)
        }
        titleByPriceLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLineView.snp.bottom).offset(UIConstants.TitleByPriceLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.TitleByPriceLabel.leftOffset)
            $0.right.equalToSuperview()
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(titleByPriceLabel.snp.bottom).offset(UIConstants.FuelKey.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.FuelKey.leftOffset)
        }
        highOilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.bottom).offset(UIConstants.FuelKey.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.FuelKey.leftOffset)
        }
        diselKeyLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.bottom).offset(UIConstants.FuelKey.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.FuelKey.leftOffset)
        }
        lpgKeyLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.bottom).offset(UIConstants.FuelKey.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.FuelKey.leftOffset)
        }
        oilValueLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.top)
            $0.left.equalTo(oilKeyLabel.snp.left).offset(UIConstants.FuelValue.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.FuelValue.rightOffset)
        }
        highOilValueLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.top)
            $0.left.equalTo(highOilKeyLabel.snp.left).offset(UIConstants.FuelValue.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.FuelValue.rightOffset)
        }
        diselValueLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.top)
            $0.left.equalTo(diselKeyLabel.snp.left).offset(UIConstants.FuelValue.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.FuelValue.rightOffset)
        }
        lpgValueLabel.snp.makeConstraints {
            $0.top.equalTo(lpgKeyLabel.snp.top)
            $0.left.equalTo(lpgKeyLabel.snp.left).offset(UIConstants.FuelValue.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.FuelValue.rightOffset)
        }
    }
}
