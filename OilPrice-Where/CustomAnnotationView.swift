//
//  CustomAnnotationView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 6..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import MapKit

// 메인페이지의 지도부분에 표시되는 어노테이션의 말풍선의 표시,
// 어노테이션의 위치와 스테이션 정보를 가지고 있는 커스텀 어노테이션
class ImageAnnotation : NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D // 어노테이션의 위치
    var title: String? // 클릭시 뜨는 말풍선
    var subtitle: String? // 말풍선 내부의 subTitle
    var colour: UIColor? // 어노테이션 컬러
    var stationInfo: GasStation? // 어노테이션에 표시할 주유소 데이터
    
    override init() {
        self.coordinate = CLLocationCoordinate2D()
        self.title = nil // title을 nil로 설정 (클릭 시 말풍선이 뜨지않는다.)
        self.subtitle = nil // subtitle을 nil로 설정 (클릭 시 subtitle이 뜨지않는다.)
        self.stationInfo = nil // 주유소 정보를 받기 전까지는 초기 값은 nil로 설정
        self.colour = UIColor.white // 기본 컬러
    }
}

// 어노테이션의 실질적인 모습을 가진 뷰
class ImageAnnotationView: MKAnnotationView {
    var firstImageView: UIImageView!
    private var logoImageView: UIImageView!
    var priceLabel: UILabel!
    var coordinate: CLLocationCoordinate2D?
    var stationInfo: GasStation?
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        
        self.frame = CGRect(x: 0, y: 0, width: 65, height: 32)
        self.firstImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 32))
        self.firstImageView.image = UIImage(named: "NonMapMarker")
        self.logoImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 15, height: 15))
        
        self.priceLabel = UILabel(frame: CGRect(x: 23, y: 3.5, width: 37, height: 18))
        self.priceLabel.textAlignment = .left
        self.priceLabel.textColor = UIColor.black
        self.priceLabel.font = UIFont.boldSystemFont(ofSize: 13)
        
        self.addSubview(self.firstImageView)
        self.addSubview(self.priceLabel)
        self.addSubview(self.logoImageView)
        
        self.firstImageView.layer.masksToBounds = true
    }
    
    override var image: UIImage? {
        get {
            return self.logoImageView.image
        }
        
        set {
            self.logoImageView.image = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
