//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SnapKit
import Then
import Combine
import CombineCocoa
import FirebaseAnalytics

protocol FavoriteCollectionViewCellDelegate: AnyObject {
    func touchedAddressLabel()
    func touchedDirection(station: GasStation?)
}

//MARK: 즐겨찾는 주유소 Cell
class FavoriteCollectionViewCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: FavoriteCollectionViewCellDelegate?
    var id = ""
    var viewModel = FavoriteCellViewModel()
    private let emptyView = UIView()
    private let loadingView = LodingView()
    private let navigationView = CustomNavigationView()
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let gasStationNameLabel = UILabel().then {
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
    private let topLineView = UIView().then { // 상단 구분선
        $0.backgroundColor = .opaqueSeparator
    }
    private let addressHStackView = CustomKVView().then { // 주소
        $0.keyLabel.text = "주소"
    }
    private let phoneNumberHStackView = CustomKVView().then { // 전화
        $0.keyLabel.text = "전화"
    }
    private let qualityHStackView = CustomKVView().then { // 품질 인증 주유소 여부
        $0.keyLabel.text = "품질인증주유소 여부"
    }
    private let bottomLineView = UIView().then { // 하단 구분선
        $0.backgroundColor = .opaqueSeparator
    }
    private let typeOfOilLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    private let oilPriceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 30)
    }
    private lazy var deleteFavoriteButton = UIButton().then {
        let favImage = Asset.Images.favoriteOnIcon.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(favImage, for: .normal)
        $0.setImage(Asset.Images.favoriteOnIcon.image, for: .highlighted)
        $0.imageView?.tintColor = .white
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = 6
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        backgroundColor = .white
        
        contentView.addSubview(logoImageView)
        contentView.addSubview(gasStationNameLabel)
        contentView.addSubview(carWashVStackView)
        contentView.addSubview(repairVStackView)
        contentView.addSubview(convenienceVStackView)
        contentView.addSubview(topLineView)
        contentView.addSubview(addressHStackView)
        contentView.addSubview(phoneNumberHStackView)
        contentView.addSubview(qualityHStackView)
        contentView.addSubview(bottomLineView)
        contentView.addSubview(oilPriceLabel)
        contentView.addSubview(typeOfOilLabel)
        contentView.addSubview(deleteFavoriteButton)
        contentView.addSubview(navigationView)
        contentView.addSubview(emptyView)
        
        logoImageView.snp.makeConstraints {
            $0.left.top.equalToSuperview().offset(20)
            $0.size.equalTo(50)
        }
        gasStationNameLabel.snp.makeConstraints {
            $0.left.equalTo(logoImageView.snp.right).offset(8)
            $0.right.equalToSuperview().offset(-20)
            $0.centerY.equalTo(logoImageView)
        }
        carWashVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        repairVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.left.equalTo(carWashVStackView.snp.right).offset(8)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        convenienceVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(12)
            $0.left.equalTo(repairVStackView.snp.right).offset(8)
            $0.width.equalTo(30)
            $0.height.equalTo(47)
        }
        topLineView.snp.makeConstraints {
            $0.top.equalTo(convenienceVStackView.snp.bottom).offset(14)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        addressHStackView.snp.makeConstraints {
            $0.top.equalTo(topLineView.snp.bottom).offset(14)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(17)
        }
        phoneNumberHStackView.snp.makeConstraints {
            $0.top.equalTo(addressHStackView.snp.bottom).offset(14)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(17)
        }
        qualityHStackView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberHStackView.snp.bottom).offset(14)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(17)
        }
        bottomLineView.snp.makeConstraints {
            $0.top.equalTo(qualityHStackView.snp.bottom).offset(14)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        oilPriceLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLineView.snp.bottom).offset(46)
            $0.left.equalTo(typeOfOilLabel.snp.right).offset(8)
            $0.right.equalToSuperview().inset(20)
            $0.height.equalTo(34)
        }
        typeOfOilLabel.snp.makeConstraints {
            $0.bottom.equalTo(oilPriceLabel)
            $0.left.equalToSuperview().offset(20)
            $0.height.equalTo(23)
        }
        deleteFavoriteButton.snp.makeConstraints {
            $0.top.equalTo(oilPriceLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(20)
            $0.width.equalTo(80)
            $0.height.equalTo(40)
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(oilPriceLabel.snp.bottom).offset(12)
            $0.left.equalTo(deleteFavoriteButton.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
    
    //MARK: - Rx Binding ..
    func bindViewModel() {
        viewModel.isLoadingSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoad in
                guard let owner = self else { return }
                isLoad ? owner.loadingView.activityIndicator.startAnimating() : owner.loadingView.activityIndicator.stopAnimating()
                owner.loadingView.isHidden = isLoad
            }
            .store(in: &viewModel.cancelBag)

        // 로고 이미지 삽입
        viewModel.infoSubject
            .map { Preferences.logoImage(logoName: $0?.brand) }
            .assign(to: \.image, on: logoImageView)
            .store(in: &viewModel.cancelBag)

        // 주유소 이름
        viewModel.infoSubject
            .map { $0?.name }
            .assign(to: \.text, on: gasStationNameLabel)
            .store(in: &viewModel.cancelBag)

        // 주유소 편의시설 정보
        viewModel.infoSubject
            .sink { [weak self] info in
                guard let owner = self else { return }

                owner.carWashVStackView.valueImageView.tintColor = owner.viewModel.getActivatedColor(info: info?.carWash)
                owner.repairVStackView.valueImageView.tintColor = owner.viewModel.getActivatedColor(info: info?.repairShop)
                owner.convenienceVStackView.valueImageView.tintColor = owner.viewModel.getActivatedColor(info: info?.convenienceStore)
            }
            .store(in: &viewModel.cancelBag)

        // 주소
        viewModel.infoSubject
            .compactMap { $0?.address }
            .map { NSAttributedString(string: $0, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]) }
            .assign(to: \.attributedText, on: addressHStackView.valueLabel)
            .store(in: &viewModel.cancelBag)

        // 주소 복사
        addressHStackView.valueLabel
            .gesture()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self,
                      let valueString = owner.addressHStackView.valueLabel.text else { return }
                UIPasteboard.general.string = valueString

                owner.delegate?.touchedAddressLabel()
            }
            .store(in: &viewModel.cancelBag)

        // 전화번호
        viewModel.infoSubject
            .compactMap { $0?.phoneNumber }
            .map { NSAttributedString(string: $0, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]) }
            .assign(to: \.attributedText, on: phoneNumberHStackView.valueLabel)
            .store(in: &viewModel.cancelBag)

        // 전화 걸기
        phoneNumberHStackView.valueLabel
            .gesture()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self,
                      let valueString = owner.phoneNumberHStackView.valueLabel.text,
                      let url = URL(string: "tel:" + valueString),
                      UIApplication.shared.canOpenURL(url) else { return }

                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            .store(in: &viewModel.cancelBag)

        // 품질 인증
        viewModel.infoSubject
            .map { $0?.qualityCertification == "Y" ? "인증" : "미인증" }
            .assign(to: \.text, on: qualityHStackView.valueLabel)
            .store(in: &viewModel.cancelBag)

        // 오일 타입
        DefaultData.shared.oilSubject
            .map { Preferences.oil(code: $0) }
            .assign(to: \.text, on: typeOfOilLabel)
            .store(in: &viewModel.cancelBag)

        // 길 찾기
        navigationView
            .gesture()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }

                let event = "tap_favorite_navigation"
                let parameters = [
                    "file": #file,
                    "function": #function,
                    "eventDate": DefaultData.shared.currentTime
                ]

                Analytics.setUserProperty("ko", forName: "country")
                Analytics.logEvent(event, parameters: parameters)

                owner.delegate?.touchedDirection(station: owner.viewModel.navigationButton())
            }
            .store(in: &viewModel.cancelBag)

        // 즐겨찾기 삭제
        deleteFavoriteButton
            .tapPublisher
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: true)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }

                let event = "tap_favorite_remove"
                let parameters = [
                    "file": #file,
                    "function": #function,
                    "eventDate": DefaultData.shared.currentTime
                ]

                Analytics.setUserProperty("ko", forName: "country")
                Analytics.logEvent(event, parameters: parameters)

                owner.viewModel.deleteAction(id: owner.id)

                guard let vc = UIApplication.shared.customKeyWindow?.visibleViewController as? UIViewController else { return }
                let lbl = Preferences.showToast(width: 240, message: "즐겨 찾는 주유소가 삭제되었습니다.", numberOfLines: 1)

                vc.view.hideToast()
                vc.view.showToast(lbl, position: .bottom)
            }
            .store(in: &viewModel.cancelBag)
        
        viewModel.infoSubject.combineLatest(DefaultData.shared.oilSubject)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] station, title in
                guard let owner = self else { return }
                owner.oilPriceLabel.text = owner.viewModel.displayPriceInfomation(priceList: station?.price)
            }
            .store(in: &viewModel.cancelBag)
    }
}
