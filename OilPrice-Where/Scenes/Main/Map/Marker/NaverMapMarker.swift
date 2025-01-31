//
//  NaverMapMarker.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import NMapsMap


//MARK: Naver Map Marker View
final class NaverMapMarker: NMFMarker {
    //MARK: - Properties
    var isSelected: Bool = false { didSet { configureUI() } }
    
    private let markerView: CustomAnnotationView
    
    
    //MARK: - Initializer
    init(markerType type: CustomAnnotationView.MarkerType,
         station: GasStationSummary) {
        self.markerView = CustomAnnotationView(markerType: type, station: station)
        
        super.init()
        
        configureUI()
    }
}


//MARK: - Set UI
private extension NaverMapMarker {
    func configureUI() {
        markerView.configure(isSelectedMarker: isSelected)
        iconImage = NMFOverlayImage(image: markerView.asImage())
    }
}
