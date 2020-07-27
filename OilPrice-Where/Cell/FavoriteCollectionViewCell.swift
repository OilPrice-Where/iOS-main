//
//  FavoriteCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class FavoriteCollectionViewCell: UICollectionViewCell {
   static let identifier = "FavoriteCollectionViewCell"
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
   var id: String!
   
   // KatecX, KatecY
   var katecX: Double?
   var katecY: Double?
   
   func configure(with informaionGasStaion: InformationGasStaion) {
      self.id = informaionGasStaion.id
      self.katecX = informaionGasStaion.katecX.roundTo(places: 0)
      self.katecY = informaionGasStaion.katecY.roundTo(places: 0)
      
      logoImageView.image = Preferences.logoImage(logoName: informaionGasStaion.brand) // 로고 이미지 삽입
      gasStationNameLabel.text = informaionGasStaion.name // 주유소 이름
      
      // 세차장 여부
      carWashImageView.tintColor = informaionGasStaion.carWash == "Y" ? UIColor(named: "MainColor") : .lightGray
      // 카센터 여부
      repairShopImageView.tintColor = informaionGasStaion.repairShop == "Y" ? UIColor(named: "MainColor") : .lightGray
      // 편의점 여부
      convenienceStoreImageView.tintColor = informaionGasStaion.convenienceStore == "Y" ? UIColor(named: "MainColor") : .lightGray
      
      addressLabel.text = informaionGasStaion.address // 주소
      phoneNumberLabel.text = informaionGasStaion.phoneNumber // 전화번호
      qualityCertificationLabel.text = informaionGasStaion.qualityCertification == "Y" ? "인증" : "미인증" // 품질 인증
      
      self.deleteFavoriteButton.layer.cornerRadius = 6
      self.deleteFavoriteButton.setImage(UIImage(named: "favoriteOnIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
      self.deleteFavoriteButton.imageView?.tintColor = .white
      
      self.navigationView.layer.cornerRadius = 6
      self.navigationView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
      self.navigationView.layer.borderWidth = 1.5
      tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.navigationButton))
      
      navigationView.addGestureRecognizer(tapGesture)
      
      DefaultData.shared.oilSubject
         .subscribe(onNext: { type in
            guard let price = informaionGasStaion.price.first(where: { $0.type == type }) else { return }
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

