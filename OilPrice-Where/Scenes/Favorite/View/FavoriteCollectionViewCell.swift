//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import TMapSDK
import RxSwift
import RxCocoa
import RxGesture

class FavoriteCollectionViewCell: UICollectionViewCell {
    var id = ""
    var viewModel = FavoriteCellViewModel()
    
    let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    let gasStationNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 20)
    }
    // 세차
    let carWashVStackView = KVVStackView().then {
        $0.keyLabel.text = "세차"
        $0.valueImageView.image = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
    }
    // 수리
    let repairVStackView = KVVStackView().then {
        $0.keyLabel.text = "수리"
        $0.valueImageView.image = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
    }
    // 편의점
    let convenienceVStackView = KVVStackView().then {
        $0.keyLabel.text = "편의점"
        $0.valueImageView.image = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
    }
    // 상단 구분선
    let topLineView = UIView().then {
        $0.backgroundColor = .opaqueSeparator
    }
    // 주소
    let addressHStackView = CustomKVView().then {
        $0.keyLabel.text = "주소"
    }
    // 전화
    let phoneNumberHStackView = CustomKVView().then {
        $0.keyLabel.text = "전화"
    }
    // 품질 인증 주유소 여부
    let qualityHStackView = CustomKVView().then {
        $0.keyLabel.text = "품질인증주유소 여부"
    }
    // 하단 구분선
    let bottomLineView = UIView().then {
        $0.backgroundColor = .opaqueSeparator
    }
    let typeOfOilLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 15)
    }
    let oilPriceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 30)
    }
    
    let navigationView = CustomNavigationView()
    
    lazy var deleteFavoriteButton = UIButton().then {
        let favImage = Asset.Images.favoriteOnIcon.image.withRenderingMode(.alwaysTemplate)
        $0.setImage(favImage, for: .normal)
        $0.setImage(Asset.Images.favoriteOnIcon.image, for: .highlighted)
        $0.imageView?.tintColor = .white
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = 6
    }
    
    let emptyView = UIView()
    
    let loadingView = LodingView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindViewModel()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    func bindViewModel() {
        viewModel.isLoadingSubject
            .do(onNext: { [weak self] in
                guard let self = self else { return }
                $0 ? self.loadingView.activityIndicator.stopAnimating() : self.loadingView.activityIndicator.startAnimating()
            })
            .bind(to: loadingView.rx.isHidden)
            .disposed(by: rx.disposeBag)
                
        // 로고 이미지 삽입
        viewModel.infoSubject
            .map { Preferences.logoImage(logoName: $0?.brand) }
            .bind(to: logoImageView.rx.image)
            .disposed(by: rx.disposeBag)
        
        // 주유소 이름
        viewModel.infoSubject
            .map { $0?.name }
            .bind(to: gasStationNameLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 주유소 편의시설 정보
        viewModel.infoSubject
            .subscribe(with: self, onNext: { owner, info in
                owner.carWashVStackView.valueImageView.tintColor = self.viewModel.getActivatedColor(info: info?.carWash)
                owner.repairVStackView.valueImageView.tintColor = self.viewModel.getActivatedColor(info: info?.repairShop)
                owner.convenienceVStackView.valueImageView.tintColor = self.viewModel.getActivatedColor(info: info?.convenienceStore)
            })
            .disposed(by: rx.disposeBag)
        
        // 주소
        viewModel.infoSubject
            .map { $0?.address }
            .bind(to: addressHStackView.valueLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 전화번호
        viewModel.infoSubject
            .map { $0?.phoneNumber }
            .bind(to: phoneNumberHStackView.valueLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 품질 인증
        viewModel.infoSubject
            .map { $0?.qualityCertification == "Y" ? "인증" : "미인증" }
            .bind(to: qualityHStackView.valueLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 오일 타입
        DefaultData.shared.oilSubject
            .map { Preferences.oil(code: $0) }
            .bind(to: typeOfOilLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        Observable.combineLatest(viewModel.infoSubject, DefaultData.shared.oilSubject)
            .map { [weak self] in
                guard let strongSelf = self else { return "가격정보 없음" }
                return strongSelf.viewModel.displayPriceInfomation(priceList: $0.0?.price)
            }
            .bind(to: oilPriceLabel.rx.text)
            .disposed(by: rx.disposeBag)
        
        // 길 찾기
        navigationView.rx
            .tapGesture()
            .when(.recognized)
            .subscribe(with: self, onNext: { owner, _ in
                owner.viewModel.navigationButton()
            })
            .disposed(by: rx.disposeBag)
        
        // 즐겨찾기 삭제
        deleteFavoriteButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.viewModel.deleteAction(id: owner.id)
            })
            .disposed(by: rx.disposeBag)
    }
}
