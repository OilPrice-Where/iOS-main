//
//  MainMapView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import NMapsMap
import UIKit
import RxSwift

protocol MainMapViewDelegate: AnyObject {
    func marker(didTapMarker: NMGLatLng, info: GasStation)
}
//MARK: Map Container View
final class MainMapView: UIView {
    //MARK: - Properties
    weak var delegate: MainMapViewDelegate?
    var markers = [NaverMapMarker]()
    var selectedMarker: NaverMapMarker? = nil {
        willSet {
            selectedMarker?.isSelected = false
            newValue?.isSelected = true
        }
    }
    let mapView = NMFMapView().then {
        $0.mapType = .navi
        $0.positionMode = .direction
        $0.minZoomLevel = 5.0
        $0.maxZoomLevel = 18.0
        $0.extent = NMGLatLngBounds(southWestLat: 31.43, southWestLng: 122.37, northEastLat: 44.35, northEastLng: 132)
    }
    lazy var menuButton = UIButton().then {
        $0.setImage(Asset.Images.menuIcon.image, for: .normal)
        $0.setImage(Asset.Images.menuIcon.image, for: .highlighted)
        $0.layer.cornerRadius = 21
        $0.layer.borderWidth = 0.01
        $0.layer.borderColor = UIColor.blue.cgColor
        $0.clipsToBounds = false
        $0.backgroundColor = .white
    }
    let currentLocationButton = UIButton().then {
        $0.layer.cornerRadius = 21
        $0.clipsToBounds = false
        $0.setImage(Asset.Images.currentLocationButton.image, for: .normal)
        $0.setImage(Asset.Images.currentLocationButton.image, for: .highlighted)
        $0.backgroundColor = .white
    }
    let toListButton = UIButton().then {
        if #available(iOS 15.0, *) {
            var config = UIButton.Configuration.plain()
            config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 2.5, bottom: 1.25, trailing: 0)
            $0.configuration = config
        } else {
            $0.imageEdgeInsets = UIEdgeInsets(top: 0, left: 2.5, bottom: 1.25, right: 0)
        }
        $0.setImage(Asset.Images.listButton.image, for: .normal)
        $0.setImage(Asset.Images.listButton.image, for: .highlighted)
        $0.layer.cornerRadius = 21
        $0.layer.borderWidth = 0.01
        $0.layer.borderColor = UIColor.blue.cgColor
        $0.clipsToBounds = false
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    let toFavoriteButton = UIButton().then {
        let image = Asset.Images.favoriteTabIconSel.image.withRenderingMode(.alwaysTemplate)
        $0.layer.cornerRadius = 21
        $0.layer.borderWidth = 0.01
        $0.clipsToBounds = false
        $0.setImage(image, for: .normal)
        $0.setImage(image, for: .highlighted)
        $0.tintColor = .white
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    let researchButton = UIButton().then {
        $0.layer.cornerRadius = 21
        $0.layer.borderWidth = 0.01
        $0.layer.borderColor = UIColor.blue.cgColor
        $0.setTitle("여기에서 재검색", for: .normal)
        $0.setTitle("여기에서 재검색", for: .highlighted)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 12)
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.alpha = 0.0
    }
    let plusView = PlusView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        addSubview(mapView)
        addSubview(menuButton)
        addSubview(currentLocationButton)
        addSubview(toFavoriteButton)
        addSubview(toListButton)
        addSubview(researchButton)
        addSubview(plusView)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        plusView.snp.makeConstraints {
            $0.center.equalTo(mapView)
            $0.size.equalTo(15)
        }
        
        addShadow(views: [menuButton, toListButton, researchButton, toFavoriteButton, currentLocationButton])
    }
    
    //MARK: - Method
    func moveMap(with coordinate: CLLocationCoordinate2D) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        
        mapView.moveCamera(NMFCameraUpdate(scrollTo: latLng))
    }
    
    func showMarker(list: [GasStation]) {
        resetInfoWindows()
        
        var lowPrice = list.reduce(1_000_000, { min($0, $1.price) })
        lowPrice = lowPrice == 1_000_000 ? 0 : lowPrice
        
        list.forEach { station in
            let position = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
            let marker = NaverMapMarker(type: station.price == lowPrice ? .low : .none,
                                        brand: station.brand,
                                        price: station.price)
            
            marker.position = position
            marker.mapView = mapView
            marker.userInfo = ["station": station]
            
            
            marker.touchHandler = { [weak self] overlay -> Bool in
                self?.selectedMarker = marker
                
                let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
                cameraUpdate.animation = .easeIn
                self?.mapView.moveCamera(cameraUpdate)
                self?.delegate?.marker(didTapMarker: position, info: station)
                
                return true
            }
            
            markers.append(marker)
        }
    }
    
    func resetInfoWindows() {
        markers.forEach {
            $0.mapView = nil
        }
        
        markers = []
    }
    
    func addShadow(views: [UIView], offset: CGSize = CGSize(width: 4, height: 4), color: UIColor = .black, opacity: Float = 0.4, radius: CGFloat = 5.0) {
        views.forEach { $0.addShadow(offset: offset, color: color, opacity: opacity, radius: radius) }
    }
}


