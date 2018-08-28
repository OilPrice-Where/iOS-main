//
//  DetailView.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class DetailView: UIView {

    @IBOutlet weak var logoType : UIImageView! // Logo
    @IBOutlet weak var stationName : UILabel! // 주유소 명
    @IBOutlet weak var distance : UILabel! // 거리
    @IBOutlet weak var oilPrice : UILabel! // 기름 가격
    @IBOutlet weak var oilType : UILabel! // 기름 타입
    @IBOutlet weak var detailViewBottomConstraint: NSLayoutConstraint! // Detail View Bottom Constraint
    @IBOutlet weak var favoriteButton : UIButton!
    @IBOutlet weak var navigationStartButtonView : UIView!
    @IBOutlet weak var navigationImageView : UIImageView!
    @IBOutlet weak var navigationLabel : UILabel!
    var tapGesture: UITapGestureRecognizer!
    var id: String!
    
    func configure(_ info: GasStation) {
        let kmDistance = info.distance / 1000
        
        self.id = info.id
        self.logoType.image = Preferences.logoImage(logoName: info.brand)
        self.stationName.text = info.name
        self.stationName.font = UIFont(name: "NanumSquareRoundB", size: 20)
        self.distance.text = String(kmDistance.roundTo(places: 2)) + "km"
        self.distance.font = UIFont(name: "NanumSquareRoundB", size: 10)
        self.oilPrice.text = Preferences.priceToWon(price: info.price)
        self.oilPrice.font = UIFont(name: "NanumSquareRoundEB", size: 33)
        self.oilType.text = Preferences.oil(code: DefaultData.shared.oilType)
        self.oilType.font = UIFont(name: "NanumSquareRoundB", size: 14)
        
        self.layer.cornerRadius = 6
        
        navigationStartButtonView.layer.cornerRadius = 6 // 경로보기 버튼 외곽선 Radius 값 설정
        navigationStartButtonView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        navigationStartButtonView.layer.borderWidth = 1.5
        
        favoriteButton.layer.borderWidth = 1.5
        favoriteButton.layer.cornerRadius = 6 // 즐겨찾기 버튼 외곽선 Radius 값 설정
        favoriteButton.setImage(UIImage(named: "favoriteOffIcon")?.withRenderingMode(.alwaysTemplate), for: .normal)
        favoriteButton.setImage(UIImage(named: "favoriteOnIcon")?.withRenderingMode(.alwaysTemplate), for: .selected)
        favoriteButton.layer.borderColor = UIColor(named: "MainColor")!.cgColor
        favoriteButton.addTarget(self, action: #selector(self.clickedEvent(_:)), for: .touchUpInside)
        self.favoriteButton.isSelected = false
        self.favoriteButton.backgroundColor = UIColor.white
        favoriteButton.imageView!.tintColor = UIColor(named: "MainColor")
        
        for index in 0..<DefaultData.shared.favoriteArr.count {
            if self.id == DefaultData.shared.favoriteArr[index] {
                self.favoriteButton.isSelected = true
                self.favoriteButton.backgroundColor = UIColor(named: "MainColor")
                favoriteButton.imageView!.tintColor = UIColor.white
                break
            }
        }
    }
    
    func detailViewTapGestureRecognizer(target: Any, action: Selector) {
        tapGesture = UITapGestureRecognizer(target: target, action: action)
        navigationStartButtonView.addGestureRecognizer(tapGesture)
    }
    
    @objc func clickedEvent(_ sender: UIButton) {
        guard DefaultData.shared.favoriteArr.count < 3 else {
            if sender.isSelected {
                favoriteButton.imageView!.tintColor = UIColor(named: "MainColor")
                favoriteButton.backgroundColor = UIColor.white
                for index in 0..<DefaultData.shared.favoriteArr.count {
                    if self.id == DefaultData.shared.favoriteArr[index] {
                        DefaultData.shared.favoriteArr.remove(at: index)
                        break
                    }
                }
                sender.isSelected = false
            }
            return
        }
        if sender.isSelected {
            favoriteButton.imageView!.tintColor = UIColor(named: "MainColor")
            favoriteButton.backgroundColor = UIColor.white
            for index in 0..<DefaultData.shared.favoriteArr.count {
                if self.id == DefaultData.shared.favoriteArr[index] {
                    DefaultData.shared.favoriteArr.remove(at: index)
                    break
                }
            }
            sender.isSelected = false
        } else {
            DefaultData.shared.favoriteArr.append(self.id!)
            favoriteButton.imageView!.tintColor = UIColor.white
            favoriteButton.backgroundColor = UIColor(named: "MainColor")
            sender.isSelected = true
        }
    }
}
