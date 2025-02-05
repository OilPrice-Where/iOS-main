//
//  MainMapView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CoreLocation
import Then
import SnapKit
import NMapsMap


protocol MainMapViewDelegate: AnyObject {
    func mapView(_ mapView: MainMapView, didTapMarker station: GasStationSummary)
    func mapViewDidTapMap(_ mapView: MainMapView)
    
    func mapViewDidTapFavorite(_ mapView: MainMapView)
    func mapViewDidTapResearch(_ mapView: MainMapView)
    
    func mapViewDidTapToolbar(_ mapView: MainMapView)
    func mapViewDidTapToolbarMenu(_ mapView: MainMapView)
    func mapViewDidTapToolbarList(_ mapView: MainMapView)
}


//MARK: Map Container View
final class MainMapView: UIView {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    weak var delegate: MainMapViewDelegate?
    
    private var circle: NMFCircleOverlay?
    var markers = [NaverMapMarker]()
    var selectedMarker: NaverMapMarker? = nil {
        willSet {
            selectedMarker?.isSelected = false
            newValue?.isSelected = true
        }
    }
    
    private let mapView = NMFMapView().then {
        $0.mapType = .navi
        $0.positionMode = .direction
        $0.extent = UIConstants.MapView.extent
        $0.minZoomLevel = UIConstants.MapView.minZoomLevel
        $0.maxZoomLevel = UIConstants.MapView.maxZoomLevel
    }
    private let currentLocationButton = UIButton().then {
        $0.clipsToBounds = false
        $0.setImage(UIConstants.CurrentLocationButton.image, for: .normal)
        $0.setImage(UIConstants.CurrentLocationButton.image, for: .highlighted)
        $0.backgroundColor = .white
        $0.tintColor = Asset.Colors.mainColor.color
        $0.layer.cornerRadius = UIConstants.CurrentLocationButton.cornerRadius
    }
    private let toFavoriteButton = UIButton().then {
        $0.clipsToBounds = false
        $0.setImage(UIConstants.ToFavoriteButton.image, for: .normal)
        $0.setImage(UIConstants.ToFavoriteButton.image, for: .highlighted)
        $0.tintColor = Asset.Colors.mainColor.color
        $0.backgroundColor = .white
        $0.layer.borderWidth = UIConstants.ToFavoriteButton.borderWidth
        $0.layer.cornerRadius = UIConstants.ToFavoriteButton.cornerRadius
    }
    private let researchButton = UIButton().then {
        $0.alpha = .zero
        $0.setTitle(UIConstants.ResearchButton.title, for: .normal)
        $0.titleLabel?.textColor = .white
        $0.titleLabel?.font = UIConstants.ResearchButton.font
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.layer.borderWidth = UIConstants.ResearchButton.borderWidth
        $0.layer.borderColor = UIColor.blue.cgColor
        $0.layer.cornerRadius = UIConstants.ResearchButton.cornerRadius
    }
    private let toolbarView = HomeToolbarView()
    private let mapCenterIndicatorView = MapCenterIndicatorView()
    
    //MARK: - Initializer
    init() {
        super.init(frame: .zero)
        
        makeUI()
        bindActions()
        configureActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Method
    func showMarker(list: [GasStationSummary]) {
        resetInfoWindows()
        
        var lowPrice = list.reduce(1_000_000, { min($0, $1.price) })
        lowPrice = lowPrice == 1_000_000 ? 0 : lowPrice
        
        list.forEach { station in
            let position = NMGLatLng(lat: station.coordinate.tm.lat, lng: station.coordinate.tm.lng)
            let marker = NaverMapMarker(
                markerType: station.price == lowPrice ? .low : .none,
                station: station
            )
            
            marker.position = position
            marker.mapView = mapView
            marker.userInfo = ["station": station]
            
            marker.touchHandler = { [weak self] overlay -> Bool in
                guard let self else {
                    return false
                }
                
                selectedMarker = marker
                
                let cameraUpdate = NMFCameraUpdate(scrollTo: marker.position)
                cameraUpdate.animation = .easeIn
                mapView.moveCamera(cameraUpdate)
                delegate?.mapView(self, didTapMarker: station)
                
                return true
            }
            
            markers.append(marker)
        }
    }
}


//MARK: - Methods
extension MainMapView {
    func reset() {
        toolbarView.configure()
        resetInfoWindows()
        resetSelectedMarker()
    }
    
    func resetInfoWindows() {
        markers.forEach {
            $0.mapView = nil
        }
        
        markers = []
    }
    
    func resetSelectedMarker() {
        selectedMarker?.isSelected = false
        selectedMarker = nil
    }
    
    func setHidden(_ isHidden: Bool) {
        mapCenterIndicatorView.isHidden = isHidden
        toolbarView.isHidden = isHidden
        researchButton.isHidden = isHidden
        toFavoriteButton.isHidden = isHidden
        currentLocationButton.isHidden = isHidden
    }
    
    func updatePostionBottomButtons(bottomOffset offset: CGFloat) {
        let animator = UIViewPropertyAnimator(duration: 0.2, curve: .easeInOut)
        
        animator.addAnimations {
            self.currentLocationButton.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-offset)
            }
        }
        
        animator.startAnimation()
    }
    
    func hideResearchButtonWithAnimation() {
        researchButton.alpha = .zero
        researchButton.snp.updateConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
        }
    }
}


//MARK: - MapView
private extension MainMapView {
    func bindActions() {
        // 현재 위치 버튼 탭
        currentLocationButton.tapPublisher
            .compactMap { LocationManager.shared.currentLocation }
            .sink { [weak self] currentLocation in
                guard let self else { return }
                
                moveMap(
                    scrollTo: currentLocation.coordinate,
                    animation: .easeOut
                )
            }
            .store(in: &cancellable)
        // 즐겨찾기 페이지로 이동 탭
        toFavoriteButton.tapPublisher
            .sink { [weak self] in
                guard let self else {
                    return
                }
                delegate?.mapViewDidTapFavorite(self)
            }
            .store(in: &cancellable)
        // 여기에서 재검색 탭
        researchButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                delegate?.mapViewDidTapResearch(self)
            }
            .store(in: &cancellable)
        // 상단 툴바 사이드 메뉴 이동 Tapped
        toolbarView.gesturePublisher()
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                delegate?.mapViewDidTapToolbar(self)
            }
            .store(in: &cancellable)
        // 상단 툴바 사이드 메뉴 이동 Tapped
        toolbarView.menuButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                delegate?.mapViewDidTapToolbarMenu(self)
            }
            .store(in: &cancellable)
        // 상단 툴바 리스트 페이지 이동 Tapped
        toolbarView.listButton.tapPublisher
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                delegate?.mapViewDidTapToolbarList(self)
            }
            .store(in: &cancellable)
    }
}


//MARK: - MapView
extension MainMapView {
    var currentMapCenterLocation: CLLocation {
        CLLocation(
            latitude: mapView.latitude,
            longitude: mapView.longitude
        )
    }
    
    var currentZoomLevel: CGFloat {
        mapView.cameraPosition.zoom
    }
    
    func setContentBottom(inset: CGFloat) {
        mapView.contentInset.bottom = inset
    }
    
    func configureActions() {
        mapView.touchDelegate = self
        mapView.addCameraDelegate(delegate: self)
    }
    
    func applyCircle(location: CLLocation?) {
        circle?.mapView = nil
        circle = createCircle(location: location)
        circle?.mapView = mapView
    }
    
    private func createCircle(location: CLLocation?) -> NMFCircleOverlay? {
        guard let location else {
            return nil
        }
        
        let center = NMGLatLng(from: location.coordinate)
        let circle = NMFCircleOverlay(center, radius: 5000.0, fill: .clear)
        circle.outlineColor = .systemBlue
        circle.outlineWidth = 1
        
        return circle
    }
    
    func moveMap(scrollTo coordinate: CLLocationCoordinate2D,
                 zoomTo zoom: CGFloat? = nil,
                 animation: UIView.AnimationCurve? = nil) {
        let latLng = NMGLatLng(lat: coordinate.latitude, lng: coordinate.longitude)
        let cameraUpdated = NMFCameraUpdate(scrollTo: latLng, zoomTo: zoom ?? mapView.zoomLevel)
        
        switch animation {
        case .easeInOut:
            cameraUpdated.animation = .fly
        case .easeIn:
            cameraUpdated.animation = .easeIn
        case .easeOut:
            cameraUpdated.animation = .easeOut
        case .linear:
            cameraUpdated.animation = .linear
        default:
            break
        }
        
        mapView.moveCamera(cameraUpdated)
    }
    
    func moveMarker(station: GasStationSummary) {
        delegate?.mapView(self, didTapMarker: station)
        
        selectedMarker?.isSelected = true
        selectedMarker = markers.first(where: {
            guard let station = $0.userInfo["station"] as? GasStationSummary else {
                return false
            }
            return station.stationID == station.stationID
        })
        
        moveMap(
            scrollTo: station.coordinate.location.coordinate,
            zoomTo: 15.0,
            animation: .easeIn
        )
    }
    
    func moveSearch(poi: SearchPOI) {
        moveMap(scrollTo: poi.coordinate.location.coordinate)
        toolbarView.configure(searchText: poi.name)
    }
}


//MARK: - NMFMapViewTouchDelegate
extension MainMapView: NMFMapViewTouchDelegate {
    func mapView(_ mapView: NMFMapView, didTapMap latlng: NMGLatLng, point: CGPoint) {
        resetSelectedMarker()
        delegate?.mapViewDidTapMap(self)
    }
}


//MARK: - NMFMapViewCameraDelegate
extension MainMapView: NMFMapViewCameraDelegate {
    func mapView(_ mapView: NMFMapView, cameraDidChangeByReason reason: Int, animated: Bool) {
        guard
            animated, reason == -1,
            let distance = LocationManager.shared.distance(from: .init(lat: mapView.latitude, lng: mapView.longitude)),
            distance > 2000
        else {
            return
        }
        
        let animator = UIViewPropertyAnimator(duration: 0.25, curve: .easeInOut)
        animator.addAnimations {
            self.researchButton.alpha = 1.0
            self.researchButton.snp.updateConstraints {
                $0.top.equalTo(self.safeAreaLayoutGuide).offset(68)
            }
        }
        
        animator.startAnimation()
    }
}


//MARK: - Set UI
private extension MainMapView {
    enum UIConstants {
        enum MapView {
            static let minZoomLevel: CGFloat = 5
            static let maxZoomLevel: CGFloat = 18
            static let extent: NMGLatLngBounds = .init(
                southWestLat: 31.43,
                southWestLng: 122.37,
                northEastLat: 44.35,
                northEastLng: 132
            )
        }
        
        enum CurrentLocationButton {
            static let image: UIImage = Asset.Images.currentLocationButton.image.withRenderingMode(.alwaysTemplate)
            static let cornerRadius: CGFloat = 21
            
            static let rightOffset: CGFloat = -66
            static let bottomOffset: CGFloat = -100
            static let size: CGFloat = 42
        }
        
        enum ToFavoriteButton {
            static let image: UIImage = Asset.Images.favoriteIcon.image.withRenderingMode(.alwaysTemplate)
            static let borderWidth: CGFloat = 0.01
            static let cornerRadius: CGFloat = 21
            
            static let leftOffset: CGFloat = 12
            static let size: CGFloat = 42
        }
        
        enum ResearchButton {
            static let title: String = "여기에서 재검색"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 14)
            static let borderWidth: CGFloat = 0.01
            static let cornerRadius: CGFloat = 21
            
            static let width: CGFloat = 120
            static let height: CGFloat = 42
        }
        
        enum Toolbar {
            static let title: String = "여기에서 재검색"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 14)
            static let borderWidth: CGFloat = 0.01
            static let cornerRadius: CGFloat = 21
            
            static let horizontalEdgeInsets: CGFloat = 20
            static let height: CGFloat = 50
        }
        
        enum MapCenterIndicator {
            static let height: CGFloat = 15
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(mapView)
        
        addSubview(currentLocationButton)
        addSubview(toFavoriteButton)
        addSubview(researchButton)
        addSubview(mapCenterIndicatorView)
        addSubview(toolbarView)
        
        addShadow(views: [researchButton, toFavoriteButton, currentLocationButton, toolbarView])
    }
    
    func setConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        currentLocationButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(UIConstants.CurrentLocationButton.bottomOffset)
            $0.right.equalToSuperview().offset(UIConstants.CurrentLocationButton.rightOffset)
            $0.size.equalTo(UIConstants.CurrentLocationButton.size)
        }
        toFavoriteButton.snp.makeConstraints {
            $0.bottom.equalTo(currentLocationButton.snp.bottom)
            $0.left.equalTo(currentLocationButton.snp.right).offset(UIConstants.ToFavoriteButton.leftOffset)
            $0.size.equalTo(UIConstants.ToFavoriteButton.size)
        }
        researchButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIConstants.ResearchButton.width)
            $0.height.equalTo(UIConstants.ResearchButton.height)
        }
        mapCenterIndicatorView.snp.makeConstraints {
            $0.center.equalTo(mapView)
            $0.size.equalTo(UIConstants.MapCenterIndicator.height)
        }
        toolbarView.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.Toolbar.horizontalEdgeInsets)
            $0.height.equalTo(UIConstants.Toolbar.height)
        }
    }
    
    func addShadow(
        views: [UIView],
        offset: CGSize = .init(width: 4, height: 4),
        color: UIColor = .black,
        opacity: Float = 0.4,
        radius: CGFloat = 5.0
    ) {
        views.forEach {
            $0.addShadow(
                offset: offset,
                color: color,
                opacity: opacity,
                radius: radius
            )
        }
    }
}
