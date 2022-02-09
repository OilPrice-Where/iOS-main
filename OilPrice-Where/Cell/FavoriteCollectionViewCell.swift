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
   static let identifier = "FavoriteCollectionViewCell"
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   @IBOutlet private weak var loadingView: UIView!
   
   // 이미지
   @IBOutlet weak var logoImageView: UIImageView!
   @IBOutlet weak var carWashImageView: UIImageView!
   @IBOutlet weak var repairShopImageView: UIImageView!
   @IBOutlet weak var convenienceStoreImageView: UIImageView!
   
   // 레이블
   @IBOutlet weak var gasStationNameLabel: UILabel!
   @IBOutlet weak var addressLabel: UILabel!
   @IBOutlet weak var phoneNumberLabel: UILabel!
   @IBOutlet weak var qualityCertificationLabel: UILabel!
   @IBOutlet weak var typeOfOilLabel: UILabel!
   @IBOutlet weak var oilPriceLabel: UILabel!
   @IBOutlet var navigationView: UIView!
   @IBOutlet var deleteFavoriteButton: UIButton!
   
   let favImage = UIImage(named: "favoriteOnIcon")?.withRenderingMode(.alwaysTemplate)
   var viewModel: FavoriteCellViewModel!
   
   override func awakeFromNib() {
      super.awakeFromNib()
      
      cellLayoutSetUp()
   }
   
   private func cellLayoutSetUp() {
      deleteFavoriteButton.layer.cornerRadius = 6
      deleteFavoriteButton.setImage(favImage, for: .normal)
      deleteFavoriteButton.imageView?.tintColor = .white
      
      navigationView.layer.cornerRadius = 6
      navigationView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
      navigationView.layer.borderWidth = 1.5
   }
   
   func bindViewModel() {
      viewModel.isLoadingSubject
         .do(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            $0 ? strongSelf.activityIndicator.stopAnimating() : strongSelf.activityIndicator.startAnimating()
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
         .subscribe(onNext: { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.carWashImageView.tintColor = strongSelf.viewModel.getActivatedColor(info: $0?.carWash)
            strongSelf.repairShopImageView.tintColor = strongSelf.viewModel.getActivatedColor(info: $0?.repairShop)
            strongSelf.convenienceStoreImageView.tintColor = strongSelf.viewModel.getActivatedColor(info: $0?.convenienceStore)
         })
         .disposed(by: rx.disposeBag)
      
      // 주소
      viewModel.infoSubject
         .map { $0?.address }
         .bind(to: addressLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      // 전화번호
      viewModel.infoSubject
         .map { $0?.phoneNumber }
         .bind(to: phoneNumberLabel.rx.text)
         .disposed(by: rx.disposeBag)
      
      // 품질 인증
      viewModel.infoSubject
         .map { $0?.qualityCertification == "Y" ? "인증" : "미인증" }
         .bind(to: qualityCertificationLabel.rx.text)
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
         .subscribe(onNext: { [weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.navigationButton()
         })
         .disposed(by: rx.disposeBag)
      
      // 즐겨찾기 삭제
      deleteFavoriteButton.rx.tap
         .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
         .subscribe(onNext: {[weak self] _ in
            guard let strongSelf = self else { return }
            strongSelf.viewModel.deleteAction()
         })
         .disposed(by: rx.disposeBag)
   }
}
