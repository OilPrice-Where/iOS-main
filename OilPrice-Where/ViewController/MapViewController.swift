//
//  MapViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 11..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class MapViewController: UIViewController , NMapViewDelegate, NMapPOIdataOverlayDelegate, NMapLocationManagerDelegate {
    
    // MARK:- 레이블과 이미지뷰
    @IBOutlet weak var logoImege: UIImageView!
    @IBOutlet weak var gasStationNameLabel: UILabel!
    @IBOutlet weak var distanceToGasStationLabel: UILabel!
    @IBOutlet weak var typeOfOilLabel: UILabel!
    @IBOutlet weak var oilPlice: UILabel!
    
    // MARK:- 버튼
    @IBAction func favoritesButton(_ sender: UIButton) {
    }
    @IBAction func navigationButton(_ sender: UIButton) {
    }
    
    
    
    
    var gasStations: [GasStation] = []
    
    //    @IBOutlet weak var levelStepper: UIStepper!
    var mapView: NMapView?
    var changeStateButton: UIButton?
    var location: CLLocation?
    
    enum state {
        case disabled
        case tracking
        case trackingWithHeading
    }
    
    var currentState: state = .tracking
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "gasStation"),
                                               object: nil,
                                               queue: nil) {
                                                [weak self] (noti) in
                                                if let gs = noti.object as? [GasStation] {
                                                    self?.gasStations = gs
                                                }
        }
        
        mapView?.viewDidAppear()
        
        mapView = NMapView(frame: self.view.bounds)
        
        if let mapView = mapView {
            
            // set the delegate for map view
            mapView.delegate = self
            
            // set the application api key for Open MapViewer Library
            mapView.setClientId("NMdSrEaqoUoo0bzgtlId")
            
            mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            
            view.addSubview(mapView)
            
            // Zoom 용 UIStepper 셋팅.
//            initLevelStepper(mapView.minZoomLevel(), maxValue:mapView.maxZoomLevel(), initialValue:11)
//            view.bringSubview(toFront: levelStepper)
            
//            mapView.setBuiltInAppControl(true)
            
        }
        
        // Add Controls.
        changeStateButton = createButton()
        
        if let button = changeStateButton {
            view.addSubview(button)
        }
    }
    
    // MARK: - NMapViewDelegate Methods
    open func onMapView(_ mapView: NMapView!, initHandler error: NMapError!) {
        if (error == nil) { // success
            // set map center and level
            mapView.setMapCenter(NGeoPoint(longitude:126.978371, latitude:37.5666091), atLevel:11)
            // set for retina display
            mapView.setMapEnlarged(true, mapHD: true)
            // set map mode : vector(일반지도)/satelite(위성)/hybrid(주소설명과 위성지도)
            mapView.mapViewMode = .vector
        } else { // fail
            print("onMapView:initHandler: \(error.description)")
        }
    }
    
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForOverlayItem poiItem: NMapPOIitem!, selected: Bool) -> UIImage! {
        return NMapViewResources.imageWithType(poiItem.poiFlagType, selected: selected)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, anchorPointWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return NMapViewResources.anchorPoint(withType: poiFlagType)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, calloutOffsetWithType poiFlagType: NMapPOIflagType) -> CGPoint {
        return CGPoint(x: 0, y: 0)
    }
    open func onMapOverlay(_ poiDataOverlay: NMapPOIdataOverlay!, imageForCalloutOverlayItem poiItem: NMapPOIitem!, constraintSize: CGSize, selected: Bool, imageForCalloutRightAccessory: UIImage!, calloutPosition: UnsafeMutablePointer<CGPoint>!, calloutHit calloutHitRect: UnsafeMutablePointer<CGRect>!) -> UIImage! {
        return nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        mapView?.didReceiveMemoryWarning()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapView?.viewWillAppear()
        enableLocationUpdate()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        mapView?.viewDidDisappear()
    }
    
//    func initLevelStepper(_ minValue: Int32, maxValue: Int32, initialValue: Int32) {
//        levelStepper.minimumValue = Double(minValue)
//        levelStepper.maximumValue = Double(maxValue)
//        levelStepper.stepValue = 1
//        levelStepper.value = Double(initialValue)
//    }
//
//    @IBAction func levelStepperValeChanged(_ sender: UIStepper) {
//        mapView?.setZoomLevel(Int32(sender.value))
//    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        showMarkers()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        mapView?.viewWillDisappear()
        
        stopLocationUpdating()
    }
    
    // MARK: - NMapLocationManagerDelegate Methods
    
    open func locationManager(_ locationManager: NMapLocationManager!, didUpdateTo location: CLLocation!) {
        
        let coordinate = location.coordinate
        
        let myLocation = NGeoPoint(longitude: coordinate.longitude, latitude: coordinate.latitude)
        let locationAccuracy = Float(location.horizontalAccuracy)
        
        mapView?.mapOverlayManager.setMyLocation(myLocation, locationAccuracy: locationAccuracy)
        mapView?.setMapCenter(myLocation)
    }
    
    // 위치 에러
    open func locationManager(_ locationManager: NMapLocationManager!, didFailWithError errorType: NMapLocationManagerErrorType) {
        
        var message: String = ""
        
        // 에러 타입
        switch errorType {
        case .unknown: fallthrough
        case .canceled: fallthrough
        case .timeout:
            message = "일시적으로 내위치를 확인 할 수 없습니다."
        case .denied:
            message = "위치 정보를 확인 할 수 없습니다.\n사용자의 위치 정보를 확인하도록 허용하시려면 위치서비스를 켜십시오."
        case .unavailableArea:
            message = "현재 위치는 지도내에 표시할 수 없습니다."
        case .heading:
            message = "나침반 정보를 확인 할 수 없습니다."
        }
        
        // 에러메세지가 있을 시 Alert 호출
        if (!message.isEmpty) {
            let alert = UIAlertController(title:"NMapViewer", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title:"OK", style:.default, handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        
        if let mapView = mapView, mapView.isAutoRotateEnabled {
            mapView.setAutoRotateEnabled(false, animate: true)
        }
    }
    
    func locationManager(_ locationManager: NMapLocationManager!, didUpdate heading: CLHeading!) {
        let headingValue = heading.trueHeading < 0.0 ? heading.magneticHeading : heading.trueHeading
        setCompassHeadingValue(headingValue)
    }
    
    func onMapViewIsGPSTracking(_ mapView: NMapView!) -> Bool {
        return NMapLocationManager.getSharedInstance().isTrackingEnabled()
    }
    
    func findCurrentLocation() {
        enableLocationUpdate()
    }
    
    func setCompassHeadingValue(_ headingValue: Double) {
        
        if let mapView = mapView, mapView.isAutoRotateEnabled {
            mapView.setRotateAngle(Float(headingValue), animate: true)
        }
    }
    
    func stopLocationUpdating() {
        
        disableHeading()
        disableLocationUpdate()
    }
    
    // MARK: - My Location
    
    func enableLocationUpdate() {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            
            if lm.locationServiceEnabled() == false {
                locationManager(lm, didFailWithError: .denied)
                return
            }
            
            // Location 장치 false일 시 true로 변경
            if lm.isUpdateLocationStarted() == false {
                // set delegate
                lm.setDelegate(self)
                // start updating location
                lm.startContinuousLocationInfo()
            }
        }
    }
    
    func disableLocationUpdate() {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            
            // Location 장치 true일 시 false로 변경
            if lm.isUpdateLocationStarted() {
                // start updating location
                lm.stopUpdateLocationInfo()
                // set delegate
                lm.setDelegate(nil)
            }
        }
        
        mapView?.mapOverlayManager.clearMyLocationOverlay()
    }
    
    // MARK: - Compass
    
    func enableHeading() -> Bool {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            
            let isAvailableCompass = lm.headingAvailable()
            
            if isAvailableCompass {
                
                mapView?.setAutoRotateEnabled(true, animate: true)
                
                lm.startUpdatingHeading()
            } else {
                return false
            }
        }
        
        return true;
    }
    
    func disableHeading() {
        if let lm = NMapLocationManager.getSharedInstance() {
            
            let isAvailableCompass = lm.headingAvailable()
            
            if isAvailableCompass {
                lm.stopUpdatingHeading()
            }
        }
        
        mapView?.setAutoRotateEnabled(false, animate: true)
    }
    
    // MARK: - Button Control
    
    func createButton() -> UIButton? {
        
        let button = UIButton(type: .custom)
        
        button.frame = CGRect(x: 15, y: 30, width: 36, height: 36)
        button.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
        
        button.addTarget(self, action: #selector(buttonClicked(_:)), for: .touchUpInside)
        
        return button
    }
    
    @objc func buttonClicked(_ sender: UIButton!) {
        
        if let lm = NMapLocationManager.getSharedInstance() {
            
            switch currentState {
            case .disabled:
                enableLocationUpdate()
                updateState(.tracking)
            case .tracking:
                let isAvailableCompass = lm.headingAvailable()
                if isAvailableCompass {
                    enableLocationUpdate()
                    if enableHeading() {
                        updateState(.trackingWithHeading)
                    }
                } else {
                    stopLocationUpdating()
                    updateState(.disabled)
                }
            case .trackingWithHeading:
                stopLocationUpdating()
                updateState(.disabled)
            }
        }
    }
    
    func updateState(_ newState: state) {
        
        currentState = newState
        
        switch currentState {
        case .disabled:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_normal"), for: .normal)
        case .tracking:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_selected"), for: .normal)
        case .trackingWithHeading:
            changeStateButton?.setImage(#imageLiteral(resourceName: "v4_btn_navi_location_my"), for: .normal)
        }
    }
    
    // MARK : Marker
    
    func showMarkers() {
        
        if let mapOverlayManager = mapView?.mapOverlayManager {
            
            // create POI data overlay
            if let poiDataOverlay = mapOverlayManager.newPOIdataOverlay() {
                
                poiDataOverlay.initPOIdata(Int32(gasStations.count))
                
                for i in 0..<gasStations.count {
                    let wgsPoint = convertKatecToWGS(x: gasStations[i].katecX, y: gasStations[i].katecY)
                    poiDataOverlay.addPOIitem(atLocation: NGeoPoint(longitude: wgsPoint.x,
                                                                    latitude: wgsPoint.y),
                                              title: gasStations[i].name,
                                              type: UserPOIflagTypeDefault,
                                              iconIndex: Int32(i),
                                              with: nil)
                }
                
                poiDataOverlay.endPOIdata()
                
                // show all POI data
                poiDataOverlay.showAllPOIdata()
                
                poiDataOverlay.selectPOIitem(at: Int32(gasStations.count - 1), moveToCenter: false, focusedBySelectItem: true)
                
            }
        }
    }
    
    func clearOverlays() {
        if let mapOverlayManager = mapView?.mapOverlayManager {
            mapOverlayManager.clearOverlays()
        }
    }
    
    func convertKatecToWGS(x: Double, y: Double) -> KatecPoint {
        let convert = GeoConverter()
        let katecPoint = GeographicPoint(x: x, y: y)
        let wgsPoint = convert.convert(sourceType: .KATEC, destinationType: .WGS_84, geoPoint: katecPoint)
        
        return KatecPoint(x: wgsPoint!.x.roundTo(places: 6), y: wgsPoint!.y.roundTo(places: 6))
        
    }
}
