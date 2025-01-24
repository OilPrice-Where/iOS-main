//
//  StationDetailVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit
import NMapsMap


final class StationDetailVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: StationDetailViewModel
    
    private let mapView = NMFMapView().then {
        $0.mapType = .navi
        $0.positionMode = .direction
        $0.minZoomLevel = UIConstants.MapView.minZoomLevel
        $0.maxZoomLevel = UIConstants.MapView.maxZoomLevel
        $0.extent = UIConstants.MapView.extent
        $0.layer.cornerRadius = UIConstants.MapView.cornerRadius
        $0.allowsScrolling = false
    }
    private let navigationTitleView = CustomNavigationTitleView()
    private let washImageView = UIImageView().then {
        $0.image = UIConstants.WashImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let repairImageView = UIImageView().then {
        $0.image = UIConstants.RepairImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let convenienceImageView = UIImageView().then {
        $0.image = UIConstants.ConvenienceImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let priceInfoLabel = UILabel().then {
        $0.text = UIConstants.PriceInfoLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.PriceInfoLabel.font
    }
    private let oilKeyLabel = UILabel().then {
        $0.text = UIConstants.OilKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.OilKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let highOilKeyLabel = UILabel().then {
        $0.text = UIConstants.HighOilKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.HighOilKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let diselKeyLabel = UILabel().then {
        $0.text = UIConstants.DiselKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.DiselKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let lpgKeyLabel = UILabel().then {
        $0.text = UIConstants.LpgKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.LpgKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let oilValueLabel = UILabel().then {
        $0.text = UIConstants.OilValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.OilValueLabel.font
    }
    private let highOilValueLabel = UILabel().then {
        $0.text = UIConstants.HighOilValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.HighOilValueLabel.font
    }
    private let diselValueLabel = UILabel().then {
        $0.text = UIConstants.DiselValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.DiselValueLabel.font
    }
    private let lpgValueLabel = UILabel().then {
        $0.text = UIConstants.LpgValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.LpgValueLabel.font
    }
    private let bottomLine = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    private let detailInfoLabel = UILabel().then {
        $0.text = UIConstants.DetailInfoLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.DetailInfoLabel.font
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
        $0.titleLabel?.font = UIConstants.AddressValueButton.font
    }
    private let phoneNumberValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = UIConstants.PhoneNumberValueButton.font
    }
    private let expandView = GasStationExpandView(height: UIConstants.ExpandView.height).then {
        $0.directionView.configure(message: UIConstants.ExpandView.title)
    }
    
    //MARK: - Life Cycle
    init(viewModel: StationDetailViewModel) {
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
}


//MARK: - Binding..
private extension StationDetailVC {
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
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            addressButtonTapped: addressButtonTapped,
            phoneNumberButtonTapped: phoneNumberButton,
            favoriteButtonTapped: expandView.favoriteButton.tapPublisher.eraseToAnyPublisher(),
            directionButtonTapped: expandView.gesturePublisher().map { _ in }.eraseToAnyPublisher()
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: StationDetailViewModel.Output) {
        // 토스트 노출
        output.showToast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                guard let self,
                      let visibleViewController = UIApplication.shared.customKeyWindow?.visibleViewController else {
                    return
                }
                visibleViewController.view.hideToast()
                let toast = Preferences.showToast(width: 240, message: message, numberOfLines: 2)
                visibleViewController.view.showToast(toast, position: .top)
            }
            .store(in: &cancellable)
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
        // expandView.favoriteButton
        output.updateFavoriteButton
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isFavorite in
                let favoriteImage = isFavorite ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
                self?.expandView.favoriteButton.setImage(favoriteImage.withRenderingMode(.alwaysTemplate), for: .normal)
                self?.expandView.favoriteButton.imageView?.tintColor = isFavorite ? .white : Asset.Colors.mainColor.color
                self?.expandView.favoriteButton.backgroundColor = isFavorite ? Asset.Colors.mainColor.color : .white
            }
            .store(in: &cancellable)
        // naviTitleView
        output.updateStationDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] station in
                self?.navigationTitleView.configure(with: station)
            }
            .store(in: &cancellable)
        // washImageView
        output.updateStationDetail
            .map { $0.hasCarWash ? Asset.Colors.mainColor.color : .lightGray }
            .assign(to: \.tintColor, on: washImageView)
            .store(in: &cancellable)
        // repairImageView
        output.updateStationDetail
            .map { $0.hasRepairShop ? Asset.Colors.mainColor.color : .lightGray }
            .assign(to: \.tintColor, on: repairImageView)
            .store(in: &cancellable)
        // convenienceImageView
        output.updateStationDetail
            .map { $0.hasConvenienceStore ? Asset.Colors.mainColor.color : .lightGray }
            .assign(to: \.tintColor, on: convenienceImageView)
            .store(in: &cancellable)
        // convenienceImageView
        output.updateStationDetail
            .map { $0.hasConvenienceStore ? Asset.Colors.mainColor.color : .lightGray }
            .assign(to: \.tintColor, on: convenienceImageView)
            .store(in: &cancellable)
        // addressValueButton
        output.updateStationDetail
            .map { $0.address }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] address in
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
                var underlineAttributedString = NSAttributedString(string: address, attributes: underlineAttribute)
                self?.addressValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
                self?.addressValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
            }
            .store(in: &cancellable)
        // phoneNumberValueButton
        output.updateStationDetail
            .map { $0.phoneNumber }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] phoneNumber in
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.thick.rawValue]
                var underlineAttributedString = NSAttributedString(string: phoneNumber, attributes: underlineAttribute)
                self?.phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
                self?.phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
            }
            .store(in: &cancellable)
        // mapView
        output.updateStationDetail
            .map { NMGLatLng(lat: $0.coordinate.tm.lat, lng: $0.coordinate.tm.lng) }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] position in
                let update = NMFCameraUpdate(scrollTo: position, zoomTo: 16.0)
                self?.mapView.moveCamera(update)
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
private extension StationDetailVC {
    enum UIConstants {
        enum WashImageView {
            static let image: UIImage = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -4
            static let size: CGFloat = 24
        }
        
        enum RepairImageView {
            static let image: UIImage = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -4
            static let size: CGFloat = 24
        }
        
        enum ConvenienceImageView {
            static let image: UIImage = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
            
            static let rightOffset: CGFloat = -16
            static let size: CGFloat = 24
        }
        
        enum PriceInfoLabel {
            static let text: String = "가격 정보"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 18)
            
            static let topOffset: CGFloat = 24
            static let leftOffset: CGFloat = 24
        }
        
        enum OilKeyLabel {
            static let text: String = "휘발유"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 24
        }
        
        enum HighOilKeyLabel {
            static let text: String = "고급유"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 24
        }
        
        enum DiselKeyLabel {
            static let text: String = "경유"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 24
        }
        
        enum LpgKeyLabel {
            static let text: String = "LPG"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 24
        }
        
        enum OilValueLabel {
            static let text: String = "가격 정보 없음"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum HighOilValueLabel {
            static let text: String = "가격 정보 없음"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum DiselValueLabel {
            static let text: String = "가격 정보 없음"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum LpgValueLabel {
            static let text: String = "가격 정보 없음"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum BottomLine {
            static let topOffset: CGFloat = 12
            static let height: CGFloat = 8
        }
        
        enum DetailInfoLabel {
            static let text: String = "주유소 상세정보"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 18)
            
            static let topOffset: CGFloat = 16
            static let leftOffset: CGFloat = 24
            static let rightOffset: CGFloat = -16
        }
        
        enum MapView {
            static let minZoomLevel: CGFloat = 5.0
            static let maxZoomLevel: CGFloat = 18.0
            static let cornerRadius: CGFloat = 10
            static let extent: NMGLatLngBounds = .init(southWestLat: 31.43, southWestLng: 122.37, northEastLat: 44.35, northEastLng: 132)
            
            static let topOffset: CGFloat = 24
            static let leftOffset: CGFloat = 24
            static let rightOffset: CGFloat = -16
            static let height: CGFloat = 200
        }
        
        enum AddressKeyLabel {
            static let text: String = "주소"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 24
        }
        
        enum PhoneNumberKeyLabel {
            static let text: String = "전화"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 16)
            
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 24
        }
        
        enum AddressValueButton {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum PhoneNumberValueButton {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 16)
            
            static let leftOffset: CGFloat = 6
            static let rightOffset: CGFloat = -16
        }
        
        enum ExpandView {
            static let title: String = "길 찾기"
            
            static let bottomOffset: CGFloat = -16
            static let height: CGFloat = 50
        }
    }

    
    func makeUI() {
        navigationItem.titleView = navigationTitleView
        view.backgroundColor = .white
        
        let backItem = UIBarButtonItem()
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.addSubview(navigationTitleView)
        view.addSubview(washImageView)
        view.addSubview(repairImageView)
        view.addSubview(convenienceImageView)
        view.addSubview(priceInfoLabel)
        view.addSubview(oilKeyLabel)
        view.addSubview(diselKeyLabel)
        view.addSubview(highOilKeyLabel)
        view.addSubview(lpgKeyLabel)
        view.addSubview(oilValueLabel)
        view.addSubview(diselValueLabel)
        view.addSubview(highOilValueLabel)
        view.addSubview(lpgValueLabel)
        view.addSubview(bottomLine)
        view.addSubview(detailInfoLabel)
        view.addSubview(addressKeyLabel)
        view.addSubview(phoneNumberKeyLabel)
        view.addSubview(addressValueButton)
        view.addSubview(phoneNumberValueButton)
        view.addSubview(expandView)
        view.addSubview(mapView)
    }
    
    func setConstraints() {
        washImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(repairImageView.snp.left).offset(UIConstants.WashImageView.rightOffset)
            $0.size.equalTo(UIConstants.WashImageView.size)
        }
        repairImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(convenienceImageView.snp.left).offset(UIConstants.RepairImageView.rightOffset)
            $0.size.equalTo(UIConstants.RepairImageView.size)
        }
        convenienceImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalToSuperview().offset(UIConstants.ConvenienceImageView.rightOffset)
            $0.size.equalTo(UIConstants.ConvenienceImageView.size)
        }
        priceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.PriceInfoLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.PriceInfoLabel.leftOffset)
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceInfoLabel.snp.bottom).offset(UIConstants.OilKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.OilKeyLabel.leftOffset)
        }
        highOilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.bottom).offset(UIConstants.HighOilKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.HighOilKeyLabel.leftOffset)
        }
        diselKeyLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.bottom).offset(UIConstants.DiselKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.DiselKeyLabel.leftOffset)
        }
        lpgKeyLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.bottom).offset(UIConstants.LpgKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.LpgKeyLabel.leftOffset)
        }
        oilValueLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.top)
            $0.left.equalTo(oilKeyLabel.snp.left).offset(UIConstants.OilValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.OilValueLabel.rightOffset)
        }
        highOilValueLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.top)
            $0.left.equalTo(highOilKeyLabel.snp.left).offset(UIConstants.HighOilValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.HighOilValueLabel.rightOffset)
        }
        diselValueLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.top)
            $0.left.equalTo(diselKeyLabel.snp.left).offset(UIConstants.DiselValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DiselValueLabel.rightOffset)
        }
        lpgValueLabel.snp.makeConstraints {
            $0.top.equalTo(lpgKeyLabel.snp.top)
            $0.left.equalTo(lpgKeyLabel.snp.left).offset(UIConstants.LpgValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.LpgValueLabel.rightOffset)
        }
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(lpgValueLabel.snp.bottom).offset(UIConstants.BottomLine.topOffset)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(UIConstants.BottomLine.height)
        }
        detailInfoLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLine.snp.bottom).offset(UIConstants.DetailInfoLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.DetailInfoLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DetailInfoLabel.rightOffset)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(detailInfoLabel.snp.bottom).offset(UIConstants.MapView.topOffset)
            $0.left.equalToSuperview().inset(UIConstants.MapView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.MapView.rightOffset)
            $0.height.equalTo(UIConstants.MapView.height)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(UIConstants.AddressKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.AddressKeyLabel.leftOffset)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(UIConstants.PhoneNumberKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.PhoneNumberKeyLabel.leftOffset)
        }
        addressValueButton.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(UIConstants.AddressValueButton.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.AddressValueButton.rightOffset)
        }
        phoneNumberValueButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(UIConstants.PhoneNumberValueButton.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.PhoneNumberValueButton.rightOffset)
        }
        expandView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.ExpandView.bottomOffset)
            $0.left.right.equalToSuperview()
        }
    }
}
