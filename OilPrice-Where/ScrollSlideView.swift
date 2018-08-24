//
//  ScrollSlideView.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class ScrollSlideView: UIView {

    
    // 이미지
    @IBOutlet weak var logoImageView: UIImageView!
    @IBOutlet weak var carWashImageView: UIImageView!
    @IBOutlet weak var repairShopImageView: UIImageView!
    @IBOutlet weak var convenienceStoreImageView: UIImageView!
    
    // 레이블
    @IBOutlet weak var gasStationNameLabel: UILabel!
    @IBOutlet weak var carWashLabel: UILabel!
    @IBOutlet weak var repairShopLabel: UILabel!
    @IBOutlet weak var convenienceStoreLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var qualityCertificationLabel: UILabel!
    @IBOutlet weak var typeOfOilLabel: UILabel!
    @IBOutlet weak var oilPlice: UILabel!
    
    
    // 버튼
    @IBAction func navigationButton(_ sender: UIButton) {
        let destination = KNVLocation(name: "Test", x: 321286, y: 533707)
        let options = KNVOptions()
        
        let params = KNVParams(destination: destination,
                               options: options)
        KNVNaviLauncher.shared().navigate(with: params)
    }

    
    func configure(with informaionGasStaion: InformationGasStaion) {
//        self.gasStationNameLabel.text = informaionGasStaion.name // 주유소 이름
//        
//        self.addressLabel.text = informaionGasStaion.address // 주소
//        self.phoneNumberLabel.text = informaionGasStaion.phoneNumber // 전화번호
        
//        // 품질인증확인
//        if informaionGasStaion.qualityCertification == "Y" {
//            self.qualityCertificationLabel.text = "인증"
//        } else {
//            self.qualityCertificationLabel.text = "미인증"
//        }
        
//        self.logoImageView.image = Preferences.logoImage(logoName: informaionGasStaion.brand) // 로고 이미지 삽입
//        self.typeOfOilLabel.text = Preferences.oil(code: informaionGasStaion.typeOfOil) // 오일 타입 설정
//        self.oilPlice.text = Preferences.priceToWon(price: informaionGasStaion.price) // 기름 가격 설정
        
    }

}
