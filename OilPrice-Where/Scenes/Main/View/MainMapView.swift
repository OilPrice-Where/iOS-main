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

final class MainMapView: UIView {
    //MARK: - Properties
    weak var delegate: MainMapViewDelegate?
    
    let mapView = NMFMapView().then {
        $0.positionMode = .normal
        $0.minZoomLevel = 5.0
        $0.maxZoomLevel = 18.0
        $0.extent = NMGLatLngBounds(southWestLat: 31.43, southWestLng: 122.37, northEastLat: 44.35, northEastLng: 132)
    }
    
    var markers = [NaverMapMarker]()
    var selectedMarker: NaverMapMarker? = nil {
        willSet {
            selectedMarker?.isSelected = false
            newValue?.isSelected = true
        }
    }
    
    // currentLocationButton 설정
    let currentLocationButton = UIButton().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = false
        $0.setImage(Asset.Images.currentLocationButton.image, for: .normal)
        $0.setImage(Asset.Images.currentLocationButton.image, for: .highlighted)
        $0.backgroundColor = .white
    }
    let switchButton = UIButton().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = false
        $0.setImage(Asset.Images.listButton.image, for: .normal)
        $0.setImage(Asset.Images.listButton.image, for: .highlighted)
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        addSubview(mapView)
        addSubview(currentLocationButton)
        addSubview(switchButton)
        
        mapView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        currentLocationButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(40)
        }
        
        switchButton.snp.makeConstraints {
            $0.top.equalTo(currentLocationButton.snp.bottom).offset(12)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(40)
        }
        
        currentLocationButton.addShadow(offset: CGSize(width: 4, height: 4), color: .black, opacity: 0.4, radius: 5.0)
        switchButton.addShadow(offset: CGSize(width: 4, height: 4), color: .black, opacity: 0.4, radius: 5.0)
    }
    
    func moveMap(with coordinate: CLLocationCoordinate2D) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        
        mapView.moveCamera(NMFCameraUpdate(scrollTo: latLng))
    }
    
    func showMarker(list: [GasStation]) {
        resetInfoWindows()
        
        list.forEach { station in
            let position = NMGTm128(x: station.katecX, y: station.katecY).toLatLng()
            let marker = NaverMapMarker(brand: station.brand, price: station.price)
            
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
}


