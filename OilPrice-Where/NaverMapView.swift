//
//  NaverMapView.swift
//  OilPrice-Where
//
//  Created by wargi on 1/20/24.
//  Copyright © 2024 sangwook park. All rights reserved.
//

import SwiftUI
import NMapsMap

final class NMFCoordinator: NSObject, NMFMapViewCameraDelegate, NMFMapViewTouchDelegate, CLLocationManagerDelegate {
    static let shared = NMFCoordinator()
    
    let view = NMFMapView(frame: .zero)
    
    override init() {
        super.init()
        
        view.mapType = .navi
        view.positionMode = .direction
        
        view.minZoomLevel = 5.0
        view.maxZoomLevel = 18.0
        
        view.extent = NMGLatLngBounds(
            southWestLat: 31.43,
            southWestLng: 122.37, 
            northEastLat: 44.35,
            northEastLng: 132
        )
    }
    
    func getNaverMapView() -> NMFMapView {
        view
    }
    
    
    func mapView(_ mapView: NMFMapView,
                 didTapMap latlng: NMGLatLng,
                 point: CGPoint) {
        
    }
    
    func mapView(_ mapView: NMFMapView,
                 cameraDidChangeByReason reason: Int,
                 animated: Bool) {
        guard animated && reason == -1 else { return }
        
        let centerLocation = CLLocation(
            latitude: mapView.latitude,
            longitude: mapView.longitude
        )
        
//        guard let distance = viewModel.requestLocation?.distance(from: centerLocation), distance > 2000 else { return }
//        
//        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
//        
//        animator.addAnimations {
//            self.mapContainerView.researchButton.alpha = 1.0
//            self.mapContainerView.researchButton.snp.updateConstraints {
//                $0.top.equalTo(self.view.safeAreaLayoutGuide).offset(68)
//            }
//            
//            self.view.layoutIfNeeded()
//        }
//        
//        animator.startAnimation()
    }
}


struct NaverMapView: UIViewRepresentable {
    func makeCoordinator() -> NMFCoordinator {
        NMFCoordinator.shared
    }
    
    func makeUIView(context: Context) -> NMFMapView {
        context.coordinator.getNaverMapView()
    }
    
    func updateUIView(_ uiView: NMFMapView, context: Context) {
        
    }
}
