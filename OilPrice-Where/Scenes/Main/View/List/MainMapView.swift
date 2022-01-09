//
//  MainMapView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import NMapsMap
import UIKit

final class MainMapView: UIView {
    //MARK: - Properties
    let mapView = NMFMapView()
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
}
