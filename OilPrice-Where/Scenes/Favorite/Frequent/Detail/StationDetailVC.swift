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
import RxSwift
import RxCocoa
import FirebaseAnalytics

//MARK: StationDetailVC
final class StationDetailVC: CommonViewController {
    //MARK: - Properties
    private var id: String?
    private let viewModel = StationDetailViewModel()
    private let brandImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let nameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
    }
    private let carWashVStackView = KVVStackView().then { // 세차
        $0.keyLabel.text = "세차"
        $0.valueImageView.image = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
    }
    private let repairVStackView = KVVStackView().then { // 수리
        $0.keyLabel.text = "수리"
        $0.valueImageView.image = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
    }
    private let convenienceVStackView = KVVStackView().then { // 편의점
        $0.keyLabel.text = "편의점"
        $0.valueImageView.image = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
    }
    private let topLine = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarUIView?.tintColor = .black
        UIApplication.shared.statusBarUIView?.backgroundColor = .white
        
        navigationController?.navigationBar.tintColor = .black
        navigationController?.navigationBar.backgroundColor = .white
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .white
        
        let backItem = UIBarButtonItem()
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        view.addSubview(brandImageView)
        view.addSubview(nameLabel)
        view.addSubview(carWashVStackView)
        view.addSubview(repairVStackView)
        view.addSubview(convenienceVStackView)
        view.addSubview(topLine)
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
//        view.addSubview(emptyView)
        
        brandImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.size.equalTo(30)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalTo(brandImageView.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(16)
        }
        carWashVStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        repairVStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.left.equalTo(carWashVStackView.snp.right).offset(8)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        convenienceVStackView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(16)
            $0.left.equalTo(repairVStackView.snp.right).offset(8)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        topLine.snp.makeConstraints {
            $0.top.equalTo(carWashVStackView.snp.bottom).offset(12)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(8)
        }
        priceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(topLine.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(24)
            $0.right.equalToSuperview().offset(16)
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceInfoLabel.snp.bottom).offset(10)
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
            $0.right.equalToSuperview().offset(16)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(detailInfoLabel.snp.bottom).offset(16)
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
            .accept(id)
        // favoriteButton Tapped
        expandView
            .favoriteButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.touchedFavoriteButton()
            })
            .disposed(by: rx.disposeBag)
        // directionButton Tapped
        expandView
            .directionView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.toNavigationTapped()
            })
            .disposed(by: rx.disposeBag)
        
        viewModel
            .output
            .infoSubject
            .compactMap { $0 }
            .bind(with: self, onNext: { owner, station in
                owner.brandImageView.image = Preferences.logoImage(logoName: station.brand)
                owner.nameLabel.text = station.name
                owner.carWashVStackView.valueImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.carWash)
                owner.repairVStackView.valueImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.repairShop)
                owner.convenienceVStackView.valueImageView.tintColor = owner.viewModel.fetchActivatedColor(info: station.convenienceStore)
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
                
                owner.updateFavoriteUI()
            })
            .disposed(by: bag)
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
