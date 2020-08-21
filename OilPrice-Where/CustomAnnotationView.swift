//
//  CustomAnnotationView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 6.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import MapKit

// 어노테이션의 말풍선의 표시나, 어노테이션의 위치와
// 스테이션 정보를 가지고 있는 커스텀 어노테이션
class CustomMarkerAnnotation : NSObject, MKAnnotation {
   var coordinate: CLLocationCoordinate2D // 어노테이션의 위치
   var title: String? // 클릭시 뜨는 말풍선
   var subtitle: String? // 말풍선 내부의 subTitle
   var colour: UIColor? // 어노테이션 컬러
   var stationInfo: GasStation // 어노테이션에 표시할 주유소 정보
   
   init(coordinate: CLLocationCoordinate2D, info: GasStation) {
      self.coordinate = coordinate
      self.stationInfo = info
      self.colour = UIColor.white // 기본 컬러
   }
}

// 지도에서 실질적으로 표시 되는 뷰
class CustomMarkerAnnotationView: MKAnnotationView {
   var mapMarkerImageView: UIImageView! // 지도에 표시되는 맵 마커 이미지 뷰
   private var logoImageView: UIImageView! // 맵 마커의 이미지 뷰 내부의 로고 이미지 뷰
   var priceLabel: UILabel! //맵 마커의 이미지 뷰 내부의 가격 표시 레이블
   var coordinate: CLLocationCoordinate2D? // 맵 마커의 위치
   var stationInfo: GasStation? // 마커 내부의 주유소 정보
   
   // 로고 이미지 삽입
   override var image: UIImage? {
      get {
         return logoImageView.image
      }
      set {
         logoImageView.image = newValue
      }
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   // 마커 기본 설정
   override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
      super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
      
      isUserInteractionEnabled = true
      
      // markerView 설정
      frame = CGRect(x: 0, y: 0, width: 65, height: 32)
      mapMarkerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 60, height: 32))
      mapMarkerImageView.layer.masksToBounds = true
      addSubview(mapMarkerImageView)
      
      // logoImageView 설정
      logoImageView = UIImageView(frame: CGRect(x: 5, y: 5, width: 15, height: 15))
      addSubview(logoImageView)
      
      // priceLabel 설정
      priceLabel = UILabel(frame: CGRect(x: 22, y: 4, width: 37, height: 18))
      priceLabel.textAlignment = .left
      priceLabel.font = UIFont(name: "NanumSquareRoundEB", size: 13)
      addSubview(priceLabel)
      
   }
}

extension Notification.Name {
   static let handleSelectedMarkerAction = Notification.Name(rawValue: "handleSelectedMarkerAction")
}
