//
//  CLLocationManager.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2022/01/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import CoreLocation
import RxSwift
import RxCocoa
import NMapsMap

extension CLLocationManager: HasDelegate {
    public typealias Delegate = CLLocationManagerDelegate
}

class RxCLLocationManagerDelegateProxy: DelegateProxy<CLLocationManager, CLLocationManagerDelegate>, DelegateProxyType, CLLocationManagerDelegate {
    weak private(set) var locationManager: CLLocationManager?
    
    init(locationManager: CLLocationManager) {
        self.locationManager = locationManager
        super.init(parentObject: locationManager,
                   delegateProxy: RxCLLocationManagerDelegateProxy.self)
    }
    
    static func registerKnownImplementations() {
        self.register {
            RxCLLocationManagerDelegateProxy(locationManager: $0)
        }
    }
}

extension Reactive where Base: CLLocationManager {
    var delegate: DelegateProxy<CLLocationManager, CLLocationManagerDelegate> {
        return RxCLLocationManagerDelegateProxy.proxy(for: base)
    }
    
    var didUpdateLocations: Observable<[CLLocation]> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didUpdateLocations:)))
            .map { $0[1] as? [CLLocation] }
            .compactMap { $0 }
    }
    
    var didFailWithError: Observable<Error> {
        return delegate.methodInvoked(#selector(CLLocationManagerDelegate.locationManager(_:didFailWithError:)))
            .map { $0[1] as? Error }
            .compactMap { $0 }
    }
}

extension Reactive where Base: NMFMapView {
    public var center: Binder<CLLocation> {
        return Binder(self.base) { mapView, location in
            let cameraUpdate = NMFCameraUpdate(scrollTo: NMGLatLng(lat: location.coordinate.latitude, lng: location.coordinate.longitude), zoomTo: 15.0)
            cameraUpdate.animation = .easeIn
            base.moveCamera(cameraUpdate)
        }
    }
}
