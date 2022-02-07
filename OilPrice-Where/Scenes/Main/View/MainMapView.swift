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

final class MainMapView: UIView {
    //MARK: - Properties
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
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = false
        $0.setImage(Asset.Images.currentLocationButton.image, for: .normal)
        $0.setImage(Asset.Images.currentLocationButton.image, for: .highlighted)
        $0.backgroundColor = .white
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func configureUI() {
        addSubview(mapView)
        addSubview(currentLocationButton)
        
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        currentLocationButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(50)
        }
        
        currentLocationButton.layer.shadowColor = UIColor.black.cgColor
        currentLocationButton.layer.shadowOpacity = 0.3
        currentLocationButton.layer.shadowOffset = CGSize(width: 1, height: 1)
        currentLocationButton.layer.shadowRadius = 1.5
        currentLocationButton.layer.shadowPath = UIBezierPath(roundedRect: currentLocationButton.bounds,
                                                              cornerRadius: 25).cgPath
    }
    
    func moveMap(with coordinate: CLLocationCoordinate2D) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        
        mapView.moveCamera(NMFCameraUpdate(scrollTo: latLng))
    }
    
    func showMarker(list: [GasStation]) {
        resetInfoWindows()
        
        list.forEach {
            let position = NMGTm128(x: $0.katecX, y: $0.katecY).toLatLng()
            let marker = NaverMapMarker(brand: $0.brand, price: $0.price)
            
            marker.position = position
            marker.mapView = mapView
            marker.userInfo = ["station": $0]
            
            marker.touchHandler = { [weak self] overlay -> Bool in
                self?.selectedMarker = marker
                
                let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
                cameraUpdate.animation = .easeIn
                self?.mapView.moveCamera(cameraUpdate)
                
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
