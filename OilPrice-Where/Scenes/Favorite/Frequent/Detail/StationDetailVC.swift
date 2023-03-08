//
//  StationDetailVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import NMapsMap
import Combine
import CombineCocoa
import FirebaseAnalytics

//MARK: StationDetailVC
final class StationDetailVC: CommonViewController {
    //MARK: - Properties
    private var id: String?
    private let viewModel = StationDetailViewModel()
    
    private let naviTitleView = CustomNavigationTitle()
    var washImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    var repairImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    var convenienceImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    private let priceInfoLabel = UILabel().then {
        $0.text = "가격 정보"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
    }
    private var oilKeyLabel = UILabel().then {
        $0.text = "휘발유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private var highOilKeyLabel = UILabel().then {
        $0.text = "고급유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private var diselKeyLabel = UILabel().then {
        $0.text = "경유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private var lpgKeyLabel = UILabel().then {
        $0.text = "LPG"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var oilValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private var highOilValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private var diselValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private var lpgValueLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let bottomLine = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    private let detailInfoLabel = UILabel().then {
        $0.text = "주유소 상세정보"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
    }
    var addressKeyLabel = UILabel().then {
        $0.text = "주소"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var phoneNumberKeyLabel = UILabel().then {
        $0.text = "전화"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    lazy var addressValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 16)
        $0.addTarget(self, action: #selector(fetchAddressCopy), for: .touchUpInside)
    }
    lazy var phoneNumberValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 16)
        $0.addTarget(self, action: #selector(fetchTel), for: .touchUpInside)
    }
    lazy var expandView = GasStationExpandView(height: 50).then {
        $0.directionView.configure(msg: "길 찾기")
    }
    private let emptyView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    let mapView = NMFMapView().then {
        $0.mapType = .navi
        $0.positionMode = .direction
        $0.minZoomLevel = 5.0
        $0.maxZoomLevel = 18.0
        $0.extent = NMGLatLngBounds(southWestLat: 31.43, southWestLng: 122.37, northEastLat: 44.35, northEastLng: 132)
        $0.layer.cornerRadius = 10
        $0.allowsScrolling = false
    }
    
    //MARK: - Life Cycle
    init(id: String) {
        super.init(nibName: nil, bundle: nil)
        
        self.id = id
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        navigationItem.titleView = naviTitleView
        view.backgroundColor = .white
        
        let backItem = UIBarButtonItem()
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        view.addSubview(naviTitleView)
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
        
        washImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(repairImageView.snp.left).offset(-4)
            $0.size.equalTo(24)
        }
        repairImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(convenienceImageView.snp.left).offset(-4)
            $0.size.equalTo(24)
        }
        convenienceImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalToSuperview().offset(-16)
            $0.size.equalTo(24)
        }
        priceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            $0.left.equalToSuperview().offset(24)
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceInfoLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(24)
        }
        highOilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        diselKeyLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        lpgKeyLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        oilValueLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.top)
            $0.left.equalTo(oilKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        highOilValueLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.top)
            $0.left.equalTo(highOilKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        diselValueLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.top)
            $0.left.equalTo(diselKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        lpgValueLabel.snp.makeConstraints {
            $0.top.equalTo(lpgKeyLabel.snp.top)
            $0.left.equalTo(lpgKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(lpgValueLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(8)
        }
        detailInfoLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLine.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(-16)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(detailInfoLabel.snp.bottom).offset(24)
            $0.left.equalToSuperview().inset(24)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(200)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(24)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
        }
        addressValueButton.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        phoneNumberValueButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(6)
            $0.right.equalToSuperview().offset(-16)
        }
        expandView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-16)
            $0.left.right.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        viewModel
            .input
            .requestStationsInfo
            .send(id)
        
        // favoriteButton Tapped
        expandView
            .favoriteButton
            .tapPublisher
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.touchedFavoriteButton()
            }
            .store(in: &viewModel.cancelBag)
        
        // directionButton Tapped
        expandView
            .directionView
            .gesture()
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.toNavigationTapped()
            }
            .store(in: &viewModel.cancelBag)
        
        viewModel
            .output
            .infoSubject
            .compactMap { $0 }
            .sink { [weak self] station in
                guard let owner = self else { return }
                
                owner.naviTitleView.logoImageView.image = Preferences.logoImage(logoName: station.brand)
                owner.naviTitleView.titleLabel.text = station.name
                owner.washImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.carWash)
                owner.repairImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.repairShop)
                owner.convenienceImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.convenienceStore)
                owner.oilValueLabel.text = owner.viewModel.string(station, to: "B027")
                owner.highOilValueLabel.text = owner.viewModel.string(station, to: "B034")
                owner.diselValueLabel.text = owner.viewModel.string(station, to: "D047")
                owner.lpgValueLabel.text = owner.viewModel.string(station, to: "K015")
                
                let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]
                var underlineAttributedString = NSAttributedString(string: station.address ?? "", attributes: underlineAttribute)
                owner.addressValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
                owner.addressValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
                
                underlineAttributedString = NSAttributedString(string: station.phoneNumber ?? "", attributes: underlineAttribute)
                owner.phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
                owner.phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
                
                let position = NMGTm128(x: station.katecX ?? 0.0, y: station.katecY ?? 0.0).toLatLng()
                let update = NMFCameraUpdate(scrollTo: position, zoomTo: 16.0)
                owner.mapView.moveCamera(update)
                
                owner.updateFavoriteUI()
            }
            .store(in: &viewModel.cancelBag)
    }
    
    @objc
    func fetchAddressCopy() {
        guard let valueString = addressValueButton.titleLabel?.text else { return }
        UIPasteboard.general.string = valueString
        
        guard let vc = UIApplication.shared.customKeyWindow?.visibleViewController as? UIViewController else { return }
        let lbl = Preferences.showToast(message: "주유소 주소가 복사되었습니다.")
        
        vc.view.hideToast()
        vc.view.showToast(lbl, position: .top)
    }
    
    @objc
    func fetchTel() {
        guard let valueString = phoneNumberValueButton.titleLabel?.text,
              let url = URL(string: "tel:" + valueString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    private func touchedFavoriteButton() {
        let event = "didTapFavoriteButton"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = id, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
                
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
            }
            return
        }
        var newFaovorites = faovorites
        isDeleted ? newFaovorites = newFaovorites.filter { $0 != _id } : newFaovorites.append(_id)
        
        DefaultData.shared.favoriteSubject.accept(newFaovorites)
        updateFavoriteUI()
        
        let msg = isDeleted ? "즐겨 찾는 주유소가 삭제되었습니다." : "즐겨 찾는 주유소에 추가되었습니다."
        let lbl = Preferences.showToast(width: 240, message: msg, numberOfLines: 1)
        view.hideToast()
        view.showToast(lbl, position: .top)
    }
    
    private func toNavigationTapped() {
        let event = "tap_main_navigation"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        requestDirection(station: viewModel.fetchStation())
    }
    
    private func updateFavoriteUI() {
        let ids = DefaultData.shared.favoriteSubject.value
        
        guard let id = id else { return }
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        DispatchQueue.main.async { [weak self] in
            self?.expandView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.expandView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
            self?.expandView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
        }
    }
}
