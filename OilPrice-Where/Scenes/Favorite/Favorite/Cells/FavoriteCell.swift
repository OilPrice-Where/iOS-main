//
//  FavoriteCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


protocol FavoriteCellDelegate: AnyObject {
    /// 주유소 즐겨찾기 삭제
    func didTapFavorite(station: GasStationDetail)
    /// 주유소 주소 복사
    func didTapAddressLabel(station: GasStationDetail)
    /// 주유소에 전화걸기
    func didTapPhoneNumberLabel(station: GasStationDetail)
    /// 길찾기 및 방문 주유소 저장
    func didTapDirectionButton(station: GasStationDetail)
}


extension FavoriteCell {
    static func cellRegistration(_ delegate: FavoriteCellDelegate, fuelType: FuelType) -> UICollectionView.CellRegistration<FavoriteCell, GasStationDetail> {
        return UICollectionView.CellRegistration<FavoriteCell, GasStationDetail> { cell, indexPath, visitStation in
            cell.delegate = delegate
            cell.configure(with: visitStation, fuelType: fuelType)
        }
    }
    
    // Configure Data
    private func configure(with station: GasStationDetail, fuelType: FuelType) {
        self.favoriteStation = station
        
        
        // 로고 이미지 삽입
        logoImageView.image = station.brand.image
        // 주유소명
        gasStationNameLabel.text = station.name
        // 선택 유종
        typeOfOilLabel.text = fuelType.displayName
        // 가격
        oilPriceLabel.text = displayPrice(fuelType: fuelType)
        // 품질 인증
        qualityHStackView.valueLabel.text = station.isQualityCertified ? "인증" : "미인증"
        // 주소
        let attributes = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]
        addressHStackView.valueLabel.attributedText = NSAttributedString(string: station.address, attributes: attributes)
        // 전화번호
        phoneNumberHStackView.valueLabel.attributedText = NSAttributedString(string: station.phoneNumber, attributes: attributes)
        // 주유소 편의시설 정보
        carWashVStackView.valueImageView.tintColor = station.hasCarWash ? Asset.Colors.mainColor.color : .lightGray
        repairVStackView.valueImageView.tintColor = station.hasRepairShop ? Asset.Colors.mainColor.color : .lightGray
        convenienceVStackView.valueImageView.tintColor = station.hasConvenienceStore ? Asset.Colors.mainColor.color : .lightGray
    }
}


//MARK: 즐겨찾는 주유소 Cell
final class FavoriteCell: UICollectionViewCell {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    weak var delegate: FavoriteCellDelegate?
    
    
    private var favoriteStation: GasStationDetail?

    private let loadingView = LodingView()
    private let logoImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private let gasStationNameLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = UIConstants.GasStationNameLabel.font
    }
    /// 세차
    private let carWashVStackView = KVVStackView().then {
        $0.keyLabel.text = UIConstants.CarWashVStackView.text
        $0.valueImageView.image = UIConstants.CarWashVStackView.image
    }
    /// 수리
    private let repairVStackView = KVVStackView().then {
        $0.keyLabel.text = UIConstants.RepairVStackView.text
        $0.valueImageView.image = UIConstants.RepairVStackView.image
    }
    /// 편의점
    private let convenienceVStackView = KVVStackView().then {
        $0.keyLabel.text = UIConstants.ConvenienceVStackView.text
        $0.valueImageView.image = UIConstants.ConvenienceVStackView.image
    }
    /// 상단 구분선
    private let topLineView = UIView().then {
        $0.backgroundColor = .opaqueSeparator
    }
    /// 주소
    private let addressHStackView = CustomKVView().then {
        $0.keyLabel.text = UIConstants.AddressHStackView.text
    }
    private let phoneNumberHStackView = CustomKVView().then { // 전화
        $0.keyLabel.text = UIConstants.PhoneNumberHStackView.text
    }
    private let qualityHStackView = CustomKVView().then { // 품질 인증 주유소 여부
        $0.keyLabel.text = UIConstants.QualityHStackView.text
    }
    private let bottomLineView = UIView().then { // 하단 구분선
        $0.backgroundColor = .opaqueSeparator
    }
    private let oilPriceLabel = UILabel().then {
        $0.textAlignment = .right
        $0.font = UIConstants.OilPriceLabel.font
    }
    private let typeOfOilLabel = UILabel().then {
        $0.textColor = .darkGray
        $0.textAlignment = .right
        $0.font = UIConstants.TypeOfOilLabel.font
    }
    private let deleteFavoriteButton = UIButton().then {
        $0.setImage(UIConstants.DeleteFavoriteButton.normaImage, for: .normal)
        $0.setImage(UIConstants.DeleteFavoriteButton.highlightedImage, for: .highlighted)
        $0.imageView?.tintColor = .white
        $0.backgroundColor = UIConstants.DeleteFavoriteButton.backgroundColor
        $0.layer.cornerRadius = UIConstants.DeleteFavoriteButton.cornerRadius
    }
    private let navigationView = CustomNavigationView()
    private let spacerView = UIView()
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Binding ..
private extension FavoriteCell {
    func bindActions() {
        // 주소 복사
        addressHStackView.valueLabel
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self,
                      let favoriteStation else {
                    return
                }
                delegate?.didTapAddressLabel(station: favoriteStation)
            }
            .store(in: &cancellable)
        // 전화 걸기
        phoneNumberHStackView.valueLabel
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self,
                      let favoriteStation else {
                    return
                }
                delegate?.didTapPhoneNumberLabel(station: favoriteStation)
            }
            .store(in: &cancellable)
        // 길 찾기
        navigationView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self,
                      let favoriteStation else {
                    return
                }
                delegate?.didTapDirectionButton(station: favoriteStation)
            }
            .store(in: &cancellable)
        // 즐겨찾기 삭제
        deleteFavoriteButton
            .tapPublisher
            .throttle(for: .milliseconds(500), scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let self,
                      let favoriteStation else {
                    return
                }
                delegate?.didTapFavorite(station: favoriteStation)
            }
            .store(in: &cancellable)
    }
    
    /// 가격 정보 얻기
    func displayPrice(fuelType: FuelType) -> String {
        guard let favoriteStation,
              let displayInfo = favoriteStation.prices.first(where: { $0.fuelType == fuelType }) else {
            return "가격정보 없음"
        }
        return displayInfo.price.decimalNumber
    }
}


//MARK: - Set UI
private extension FavoriteCell {
    enum UIConstants {
        enum ContentView {
            static let backgroundColor: UIColor = .white
            static let cornerRadius: CGFloat = 35
        }
        
        enum LogoImageView {
            static let topOffset: CGFloat = 20
            static let leftOffset: CGFloat = 20
            static let size: CGFloat = 50
        }
        
        enum GasStationNameLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 20)
            
            static let leftOffset: CGFloat = 8
            static let rightOffset: CGFloat = -20
        }
        
        enum CarWashVStackView {
            static let text: String = "세차"
            static let image: UIImage = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 20
            static let width: CGFloat = 30
            static let height: CGFloat = 47
        }
        
        enum RepairVStackView {
            static let text: String = "수리"
            static let image: UIImage = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 8
            static let width: CGFloat = 30
            static let height: CGFloat = 47
        }
        
        enum ConvenienceVStackView {
            static let text: String = "편의점"
            static let image: UIImage = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 8
            static let width: CGFloat = 30
            static let height: CGFloat = 47
        }
        
        enum TopLineView {
            static let topOffset: CGFloat = 14
            static let horizontalInsets: CGFloat = 20
            static let height: CGFloat = 1
        }
        
        enum AddressHStackView {
            static let text: String = "주소"
            
            static let topOffset: CGFloat = 14
            static let horizontalInsets: CGFloat = 20
            static let height: CGFloat = 17
        }
        
        enum PhoneNumberHStackView {
            static let text: String = "전화"
            
            static let topOffset: CGFloat = 14
            static let horizontalInsets: CGFloat = 20
            static let height: CGFloat = 17
        }
        
        enum QualityHStackView {
            static let text: String = "품질인증주유소 여부"
            
            static let topOffset: CGFloat = 14
            static let horizontalInsets: CGFloat = 20
            static let height: CGFloat = 17
        }
        
        enum BottomLineView {
            static let topOffset: CGFloat = 14
            static let horizontalInsets: CGFloat = 20
            static let height: CGFloat = 1
        }
        
        enum OilPriceLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.extraBold.font(size: 30)
            
            static let topOffset: CGFloat = 46
            static let leftOffset: CGFloat = 8
            static let rightOffset: CGFloat = 20
            static let height: CGFloat = 34
        }
        
        enum TypeOfOilLabel {
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 15)
            
            static let leftOffset: CGFloat = 20
            static let height: CGFloat = 23
        }
        
        enum DeleteFavoriteButton {
            static let cornerRadius: CGFloat = 6
            
            static let normaImage: UIImage = Asset.Images.favoriteOnIcon.image.withRenderingMode(.alwaysTemplate)
            static let highlightedImage: UIImage = Asset.Images.favoriteOnIcon.image
            static let backgroundColor: UIColor = Asset.Colors.mainColor.color
            
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 20
            static let width: CGFloat = 80
            static let height: CGFloat = 40
        }
        
        enum NavigationView {
            static let topOffset: CGFloat = 12
            static let leftOffset: CGFloat = 12
            static let rightOffset: CGFloat = -20
            static let height: CGFloat = 40
        }
        
        enum SpacerView {
            static let bottomOffset: CGFloat = -20
        }
    }
    
    func makeUI() {
        backgroundColor = UIConstants.ContentView.backgroundColor
        layer.cornerRadius = UIConstants.ContentView.cornerRadius
        
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
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
        contentView.addSubview(spacerView)
    }
    
    func setConstraints() {
        logoImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.LogoImageView.topOffset)
            $0.left.top.equalToSuperview().offset(UIConstants.LogoImageView.leftOffset)
            $0.size.equalTo(UIConstants.LogoImageView.size)
        }
        gasStationNameLabel.snp.makeConstraints {
            $0.left.equalTo(logoImageView.snp.right).offset(UIConstants.GasStationNameLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.GasStationNameLabel.rightOffset)
            $0.centerY.equalTo(logoImageView)
        }
        carWashVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(UIConstants.CarWashVStackView.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.CarWashVStackView.leftOffset)
            $0.width.equalTo(UIConstants.CarWashVStackView.width)
            $0.height.equalTo(UIConstants.CarWashVStackView.height)
        }
        repairVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(UIConstants.RepairVStackView.topOffset)
            $0.left.equalTo(carWashVStackView.snp.right).offset(UIConstants.RepairVStackView.leftOffset)
            $0.width.equalTo(UIConstants.RepairVStackView.width)
            $0.height.equalTo(UIConstants.RepairVStackView.height)
        }
        convenienceVStackView.snp.makeConstraints {
            $0.top.equalTo(logoImageView.snp.bottom).offset(UIConstants.ConvenienceVStackView.topOffset)
            $0.left.equalTo(repairVStackView.snp.right).offset(UIConstants.ConvenienceVStackView.leftOffset)
            $0.width.equalTo(UIConstants.ConvenienceVStackView.width)
            $0.height.equalTo(UIConstants.ConvenienceVStackView.height)
        }
        topLineView.snp.makeConstraints {
            $0.top.equalTo(convenienceVStackView.snp.bottom).offset(UIConstants.TopLineView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.TopLineView.horizontalInsets)
            $0.height.equalTo(UIConstants.TopLineView.height)
        }
        addressHStackView.snp.makeConstraints {
            $0.top.equalTo(topLineView.snp.bottom).offset(UIConstants.AddressHStackView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.AddressHStackView.horizontalInsets)
            $0.height.equalTo(UIConstants.AddressHStackView.height)
        }
        phoneNumberHStackView.snp.makeConstraints {
            $0.top.equalTo(addressHStackView.snp.bottom).offset(UIConstants.PhoneNumberHStackView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.PhoneNumberHStackView.horizontalInsets)
            $0.height.equalTo(UIConstants.PhoneNumberHStackView.height)
        }
        qualityHStackView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberHStackView.snp.bottom).offset(UIConstants.QualityHStackView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.QualityHStackView.horizontalInsets)
            $0.height.equalTo(UIConstants.QualityHStackView.height)
        }
        bottomLineView.snp.makeConstraints {
            $0.top.equalTo(qualityHStackView.snp.bottom).offset(UIConstants.BottomLineView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.BottomLineView.horizontalInsets)
            $0.height.equalTo(UIConstants.BottomLineView.height)
        }
        oilPriceLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLineView.snp.bottom).offset(UIConstants.OilPriceLabel.topOffset)
            $0.left.equalTo(typeOfOilLabel.snp.right).offset(UIConstants.OilPriceLabel.leftOffset)
            $0.right.equalToSuperview().inset(UIConstants.OilPriceLabel.rightOffset)
            $0.height.equalTo(UIConstants.OilPriceLabel.height)
        }
        typeOfOilLabel.snp.makeConstraints {
            $0.bottom.equalTo(oilPriceLabel)
            $0.left.equalToSuperview().offset(UIConstants.TypeOfOilLabel.leftOffset)
            $0.height.equalTo(UIConstants.TypeOfOilLabel.height)
        }
        deleteFavoriteButton.snp.makeConstraints {
            $0.top.equalTo(oilPriceLabel.snp.bottom).offset(UIConstants.DeleteFavoriteButton.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.DeleteFavoriteButton.leftOffset)
            $0.width.equalTo(UIConstants.DeleteFavoriteButton.width)
            $0.height.equalTo(UIConstants.DeleteFavoriteButton.height)
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(oilPriceLabel.snp.bottom).offset(UIConstants.NavigationView.topOffset)
            $0.left.equalTo(deleteFavoriteButton.snp.right).offset(UIConstants.NavigationView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.NavigationView.rightOffset)
            $0.height.equalTo(UIConstants.NavigationView.height)
        }
        spacerView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(UIConstants.SpacerView.bottomOffset)
        }
    }
}
