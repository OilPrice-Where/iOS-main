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
    var stationInfoView = StationInfoView()
    
    // currentLocationButton 설정
    let currentLocationButton = UIButton().then {
        $0.layer.cornerRadius = 25
        $0.clipsToBounds = false
        $0.setImage(Asset.Images.currentLocationButton.image, for: .normal)
        $0.setImage(Asset.Images.currentLocationButton.image, for: .highlighted)
        $0.backgroundColor = .white
    }
    let switchButton = UIButton().then {
        $0.layer.cornerRadius = 25
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
        addSubview(stationInfoView)
        addSubview(switchButton)
        
        mapView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
        }
        stationInfoView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(mapView.snp.bottom)
            $0.height.equalTo(178)
        }
        currentLocationButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(40)
            $0.right.equalToSuperview().offset(-20)
            $0.size.equalTo(50)
        }
        switchButton.snp.makeConstraints {
            $0.size.equalTo(50)
            $0.right.equalToSuperview().offset(-20)
            $0.bottom.equalTo(stationInfoView.snp.top).offset(-12)
        }
        
        currentLocationButton.addShadow(offset: CGSize(width: 3, height: 3), color: .black, opacity: 0.3, radius: 4.0)
        stationInfoView.addShadow(offset: CGSize(width: 0, height: -3), color: .gray, opacity: 0.3, radius: 6.0)
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
                
                self?.stationInfoView.configure(station)
                
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
