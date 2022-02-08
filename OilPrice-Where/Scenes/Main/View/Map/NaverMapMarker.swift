//
//  NaverMapMarker.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import NMapsMap

class NaverMapMarker: NMFMarker {
    
    var brand: String?
    var title: String? // 클릭시 뜨는 말풍선
    var isSelected: Bool = false { didSet { updatedLayout() } }
    var markerView = CustomAnnotationView(frame: CGRect(x: 0, y: 0, width: 60, height: 32))
        
    init(brand: String, price: Int) {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        
        self.brand = brand
        self.title = formatter.string(from: NSNumber(integerLiteral: price))
        
        super.init()
        
        
        self.updatedLayout()
    }
    
    
    func updatedLayout() {
        markerView.priceLabel.text = title
        markerView.logoImageView.image = Preferences.logoImage(logoName: brand)
        
        markerView.mapMarkerImageView.image = isSelected ? Asset.Images.selectMapMarker.image : Asset.Images.nonMapMarker.image
        markerView.priceLabel.textColor = isSelected ? .white : .black
        
        iconImage = NMFOverlayImage(image: markerView.asImage())
    }
}

// 지도에서 실질적으로 표시 되는 뷰
class CustomAnnotationView: UIView {
    var isSelected: Bool = false {
        didSet {
            print(isSelected)
            mapMarkerImageView.image = isSelected ? Asset.Images.selectMapMarker.image : Asset.Images.nonMapMarker.image
            priceLabel.textColor = isSelected ? .white : .black
        }
    }
    
    var mapMarkerImageView = UIImageView().then {
        $0.frame = CGRect(x: 0, y: 0, width: 60, height: 32)
        $0.layer.masksToBounds = true
        $0.image = Asset.Images.nonMapMarker.image
    }
    
    var logoImageView = UIImageView().then {
        $0.frame = CGRect(x: 5, y: 5, width: 15, height: 15)
    }
    
    var priceLabel = UILabel().then {
        $0.frame = CGRect(x: 20, y: 4, width: 37, height: 18)
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 13)
    }
    
    var stationInfo: GasStation? // 마커 내부의 주유소 정보
    
    // 로고 이미지 삽입
    var image: UIImage? {
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
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    func makeUI() {
        addSubview(mapMarkerImageView)
        addSubview(logoImageView)
        addSubview(priceLabel)
    }
}

extension UIView {
    func asImage() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds)
        return render.image { context in
            layer.render(in: context.cgContext)
        }
    }
}
