//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteCollectionViewCell: UICollectionViewCell {
   static let identifier = "FavoriteCollectionViewCell"
   @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
   
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
   @IBOutlet weak var oilPlice: UILabel!
   @IBOutlet var navigationView: UIView!
   @IBOutlet var deleteFavoriteButton: UIButton!
   
   var tapGesture = UITapGestureRecognizer()
   var id: String?
   let mainColor = UIColor(named: "MainColor")
   let favImage = UIImage(named: "favoriteOnIcon")?.withRenderingMode(.alwaysTemplate)
   
   // KatecX, KatecY
   var katecX: Double?
   var katecY: Double?
   
   func configure(with info: InformationGasStaion) {
      
      id = info.id
      katecX = info.katecX.roundTo(places: 0)
      katecY = info.katecY.roundTo(places: 0)
      
      logoImageView.image = Preferences.logoImage(logoName: info.brand) // 로고 이미지 삽입
      gasStationNameLabel.text = info.name // 주유소 이름
      
      carWashImageView.tintColor = info.carWash == "Y" ? mainColor : .lightGray
      repairShopImageView.tintColor = info.repairShop == "Y" ? mainColor : .lightGray
      convenienceStoreImageView.tintColor = info.convenienceStore == "Y" ? mainColor : .lightGray
      
      addressLabel.text = info.address // 주소
      phoneNumberLabel.text = info.phoneNumber // 전화번호
      qualityCertificationLabel.text = info.qualityCertification == "Y" ? "인증" : "미인증" // 품질 인증
      
      deleteFavoriteButton.layer.cornerRadius = 6
      deleteFavoriteButton.setImage(favImage, for: .normal)
      deleteFavoriteButton.imageView?.tintColor = .white
      
      navigationView.layer.cornerRadius = 6
      navigationView.layer.borderColor = mainColor?.cgColor
      navigationView.layer.borderWidth = 1.5
      tapGesture = UITapGestureRecognizer(target: self, action: #selector(navigationButton))
      
      navigationView.addGestureRecognizer(tapGesture)
      
      DefaultData.shared.oilSubject
         .subscribe(onNext: { type in
            guard let price = info.price.first(where: { $0.type == type }) else { return }
            self.typeOfOilLabel.text = Preferences.oil(code: type)
            self.oilPlice.text = Preferences.priceToWon(price: price.price)
         })
         .disposed(by: rx.disposeBag)
   }
   
   @IBAction private func deleteAction(_ sender: Any) {
      guard let oldFavArr = try? DefaultData.shared.favoriteSubject.value() else { return }
      
      let newFavArr = oldFavArr.filter { self.id != $0 }
      DefaultData.shared.favoriteSubject.onNext(newFavArr)
   }
   
   // 길 안내
   @objc func navigationButton(_ sender: UIButton) {
      guard let katecX = self.katecX,
         let katecY = self.katecY,
         let name = gasStationNameLabel.text else { return }
      let destination = KNVLocation(name: name,
                                    x: NSNumber(value: katecX),
                                    y: NSNumber(value: katecY))
      let options = KNVOptions()
      
      let params = KNVParams(destination: destination,
                             options: options)
      KNVNaviLauncher.shared().navigate(with: params)
   }
}

