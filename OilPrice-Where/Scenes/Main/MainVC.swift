//
//  MainVC.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import CoreLocation
import UIKit
import Combine
import NMapsMap
import SideMenu
import Firebase
import FloatingPanel


//MARK: Main Map VC
final class MainVC: CommonViewController {
    //MARK: - Properties
    var ref: DatabaseReference?
    let viewModel = MainViewModel()
    private lazy var fpc = FloatingPanelController()
    /// 주유소 상세 정보
    private let stationDetailInfoVC: StationInfoVC
    
    private lazy var mapContainerView = MainMapView()
    private lazy var guideView = StationInfoGuideView()
    
    private var noti: NSObjectProtocol?
    var bottomOffset: CGFloat = 36
    let emptyView = UIView().then {
        $0.backgroundColor = .white
    }
    let sideMenu: SideMenuNavigationController = {
        let storage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: storage)
        let appVersionRepository: AppVersionRepository = FirebaseAppVersionRepository()
        let appVersionUseCase: AppVersionUseCase = AppVersionUseCaseImpl(appVersionRepository: appVersionRepository)
        let menuViewModel = MenuViewModel(settingUseCase: settingUseCase, appVersionUseCase: appVersionUseCase)
        let menuVC = MenuVC(viewModel: menuViewModel)
        let sideMenu = SideMenuNavigationController(rootViewController: menuVC)
        sideMenu.leftSide = true
        sideMenu.settings = {
            var settings = SideMenuSettings()
            settings.statusBarEndAlpha = 0
            settings.presentationStyle = SideMenuPresentationStyle.menuSlideIn
            settings.presentationStyle.presentingEndAlpha = 0.65
            let screenWidth = UIScreen.main.bounds.width
            settings.menuWidth = UIDevice.current.userInterfaceIdiom == .pad ? 328.0 : screenWidth * (240 / 375)
            settings.blurEffectStyle = nil
            return settings
        }()
        return sideMenu
    }()
    
    //MARK: - Life Cycle
    init() {
        let settingStorage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
        let stationRepository: StationRepository = StationRepositoryImpl()
        let stationInfoViewModel: StationInfoViewModel = StationInfoViewModel(
            settingUseCase: settingUseCase,
            stationRepository: stationRepository
        )
        self.stationDetailInfoVC = StationInfoVC(viewModel: stationInfoViewModel)
        
        super.init(nibName: nil, bundle: nil)
        
        let searchPathRepository = TMapSearchPathRepository()
        LocationManager.shared.setLocationManager(searchPathRepository: searchPathRepository)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    deinit {
        if let noti {
            NotificationCenter.default.removeObserver(noti)
        }
        self.noti = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configure()
        rxBind()
        appVersionCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarUIView?.backgroundColor = .clear
    }
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "주유 정보"
        view.backgroundColor = .white
        view.addSubview(mapContainerView)
        
        setupView()
        fpc.view.addSubview(guideView)
        fpc.view.addSubview(emptyView)
        
        mapContainerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        guideView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(82)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(guideView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func updateFavoriteUI() {
        let ids = DefaultData.shared.favoriteSubject.value
        
        guard let id = viewModel.selectedStation?.stationID else { return }
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        DispatchQueue.main.async { [weak self] in
            self?.guideView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.guideView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
            self?.guideView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
        }
    }
    
    private func configure() {
        mapContainerView.delegate = self
    }
    
    //MARK: - Rx Binding..
    private func rxBind() {
        noti = NotificationCenter.default.addObserver(forName: NSNotification.Name("liveActivities"),
                                                      object: nil,
                                                      queue: .main) { [weak self] _ in
            guard let location = LocationManager.shared.requestLocation else { return }
            
            self?.viewModel.isLiveActivities = true
            self?.viewModel.requestLocation = location
            self?.viewModel.input.requestStaions.send(nil)
        }
        
        SettingType.allCases.forEach {
            NotificationCenter.default.publisher(for: $0.notificationName)
                .receive(on: DispatchQueue.main)
                .sink { [weak self] _ in
                    self?.fpc.move(to: .hidden, animated: false, completion: nil)
                }
                .store(in: &viewModel.cancellable)
        }
        
        DefaultData.shared.completedRelay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] key in
                guard let self,
                      !(key == "Favorites" || key == "LocalFavorites") else {
                    self?.updateFavoriteUI()
                    return
                }
                
                mapContainerView.resetSelectedMarker()
                DispatchQueue.main.async {
                    self.fpc.move(to: .hidden, animated: false, completion: nil)
                }
            }
            .store(in: &viewModel.cancellable)
        
        LocationManager.shared.$currentLocation
            .compactMap { $0 }
            .sink { [weak self] currentLocation in
                guard let self,
                      viewModel.requestLocation == nil else {
                    return
                }
                
                viewModel.requestLocation = currentLocation
                viewModel.input.requestStaions.send(nil)
                
                mapContainerView.moveMap(scrollTo: currentLocation.coordinate)
            }
            .store(in: &viewModel.cancellable)
        
        // favoriteButton Tapped
        guideView
            .favoriteButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.touchedFavoriteButton()
            }
            .store(in: &viewModel.cancellable)
        
        // directionButton Tapped
        guideView
            .directionButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.toNavigationTapped()
            }
            .store(in: &viewModel.cancellable)
        
        viewModel.output.staionResult
            .sink { [weak self] _ in
                guard let self else { return }
                
                mapContainerView.applyCircle(location: viewModel.requestLocation)
                mapContainerView.showMarker(list: viewModel.stations)
                
                NotificationCenter.default.post(
                    name: NSNotification.Name("stationsUpdated"),
                    object: nil,
                    userInfo: ["stations": viewModel.stations]
                )
                
                guard let targetStation = LocationManager.shared.findStation,
                      let info = LocationManager.shared.stations.first(where: { $0.stationID == targetStation.id }),
                      let lat = targetStation.lat, let lng = targetStation.lng else { return }
                
                sideMenu.dismiss(animated: false)
                mapView(mapContainerView, didTapMarker: info)
                mapContainerView.selectedMarker = mapContainerView.markers.first(where: {
                    guard let station = $0.userInfo["station"] as? GasStationSummary else { return false }
                    return station.stationID == targetStation.id
                })
                mapContainerView.selectedMarker?.isSelected = true
                
                mapContainerView.moveMap(
                    scrollTo: .init(latitude: lat, longitude: lng),
                    zoomTo: 15.0,
                    animation: .easeIn
                )
                
                mapContainerView.hideResearchButtonWithAnimation()
            }
            .store(in: &viewModel.cancellable)
        
        // 즐겨찾기 목록의 StationID 값과 StationView의 StationID값이 동일 하면 선택 상태로 변경
        viewModel.output.selectedStation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.updateFavoriteUI()
            }
            .store(in: &viewModel.cancellable)
    }
    
    //MARK: - Override Method
    override func setNetworkSetting() {
        super.setNetworkSetting()
        
        reachability?.whenReachable = { [weak self] _ in
            self?.viewModel.input.requestStaions.send(nil)
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            self?.notConnect()
            self?.viewModel.requestLocation = nil
            LocationManager.shared.currentLocation = nil
            self?.mapContainerView.reset()
            self?.fpc.move(to: .hidden, animated: false, completion: nil)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sideMenu.dismiss(animated: false)
    }
    
    func fetchSideMenuWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width
        return UIDevice.current.userInterfaceIdiom == .pad ? 328.0 : screenWidth * (240 / 375)
    }
    
    //MARK: - User Intraction
    private func researchStation(with coordinate: CLLocationCoordinate2D? = nil) {
        let requestLocation: CLLocation
        if let coordinate {
            requestLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        } else {
            requestLocation = mapContainerView.currentMapCenterLocation
        }
        
        viewModel.requestLocation = requestLocation
        viewModel.selectedStation = nil
        mapContainerView.reset()
        viewModel.input.requestStaions.send(nil)
        viewModel.zoomLevel = nil
        
        fpc.move(to: .hidden, animated: false) { [weak self] in
            guard let self else { return }
            
            mapContainerView.hideResearchButtonWithAnimation()
        }
    }
    
    private func touchedFavoriteButton() {
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = viewModel.selectedStation?.stationID, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
        
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
            }
            return
        }
        var newFaovorites = faovorites
        isDeleted ? newFaovorites = newFaovorites.filter { $0 != _id } : newFaovorites.append(_id)
        
        DefaultData.shared.favoriteSubject.send(newFaovorites)
        updateFavoriteUI()
        
        let msg = isDeleted ? "즐겨 찾는 주유소가 삭제되었습니다." : "즐겨 찾는 주유소에 추가되었습니다."
        let lbl = Preferences.showToast(width: 240, message: msg, numberOfLines: 1)
        view.hideToast()
        view.showToast(lbl, position: .top)
    }
    
    private func toNavigationTapped() {
        requestDirection(station: viewModel.selectedStation)
    }
    
    private func appVersionCheck() {
        ref = Database.database().reference()
        guard let _ref = ref else { return }
        
        let data = _ref.child("version")
        
        data.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            guard let versionData = snapshot.value as? NSDictionary,
                  let versionDic = versionData as? [String: String],
                  let lastest_version_code = versionDic["lastest_version_code"],
                  let lastest_version_name = versionDic["lastest_version_name"],
                  let minimum_version_code = versionDic["minimum_version_code"],
                  let minimum_version_name = versionDic["minimum_version_name"]
            else { return }
            
            let versionDbData = DatabaseVersionModel(
                latestVersionCode: lastest_version_code,
                latestVersionName: lastest_version_name,
                minimumVersionCode: minimum_version_code,
                minimumVersionName: minimum_version_name
            )
            
            self?.checkUpdateVersion(versionData: versionDbData)
        })
    }
    
    private func bottomAnimation(state: FloatingPanelState) {
        guard (state == .hidden && bottomOffset != 36.0) ||
                ((state == .half || state == .full) && bottomOffset != 192.0) else { return }
        
        bottomOffset = state == .hidden ? 36.0 : 192.0
        let resultBottomOffset = bottomOffset + view.safeAreaInsets.bottom
        
        mapContainerView.updatePostionBottomButtons(bottomOffset: resultBottomOffset)
    }
}

//MARK: - Search 관련
extension MainVC: SearchBarDelegate {
    func search(poi: SearchPOI) {
        mapContainerView.moveSearch(poi: poi)
        researchStation(with: poi.coordinate.location.coordinate)
    }
}

//MARK: - NaverMap 관련
extension MainVC: MainMapViewDelegate {
    func mapView(_ mapView: MainMapView, didTapMarker station: GasStationSummary) {
        if fpc.state == .hidden { fpc.move(to: .half, animated: true, completion: nil) }
        
        viewModel.selectedStation = station
        stationDetailInfoVC.configure(station: station)
        
        let distance = station.distance < 1000 ? "\(Int(station.distance))m" : String(format: "%.1fkm", station.distance / 1000)
        guideView.directionButton.setTitle(distance + " 안내시작", for: .normal)
        guideView.directionButton.setTitle(distance + " 안내시작", for: .highlighted)
    }
    
    func mapViewDidTapMap(_ mapView: MainMapView) {
        guard fpc.state != .hidden else { return }
        viewModel.beforeNAfter.before = .hidden
        fpc.move(to: .hidden, animated: true, completion: nil)
    }
    
    func mapViewDidTapFavorite(_ mapView: MainMapView) {
        let tabbar = FavoriteTabbarController()
        navigationController?.pushViewController(tabbar, animated: true)
    }
    
    func mapViewDidTapResearch(_ mapView: MainMapView) {
        researchStation()
    }
    
    func mapViewDidTapToolbar(_ mapView: MainMapView) {
        let searchStorage: SearchPOIStorage = CoreDataSearchPOIStorage()
        let searchViewModel: SearchBarViewModel = .init(searchPOIStorage: searchStorage)
        let searchVC = SearchBarVC(viewModel: searchViewModel)
        searchVC.delegate = self
        navigationController?.pushViewController(searchVC, animated: true)
    }
    
    func mapViewDidTapToolbarMenu(_ mapView: MainMapView) {
        present(sideMenu, animated: true, completion: nil)
    }
    
    func mapViewDidTapToolbarList(_ mapView: MainMapView) {
        let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
        let settingStorage: SettingStorage = PlistSettingStorage()
        let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
        let listViewModel = MainListViewModel(
            stations: viewModel.stations,
            settingUseCase: settingUseCase,
            visitedStationStorage: visitedStationStorage
        )
        let listVC = MainListVC(viewModel: listViewModel)
        listVC.delegate = self
        navigationController?.pushViewController(listVC, animated: true)
    }
}


//MARK: - FloatingPanel 관련
extension MainVC: FloatingPanelControllerDelegate {
    func setupView() {
        fpc.contentMode = .fitToBounds
        fpc.changePanelStyle() // panel 스타일 변경 (대신 bar UI가 사라지므로 따로 넣어주어야함)
        fpc.delegate = self
        fpc.set(contentViewController: stationDetailInfoVC) // floating panel에 삽입할 것
        fpc.addPanel(toParent: self) // fpc를 관리하는 UIViewController
        fpc.layout = MyFloatingPanelLayout()
        fpc.invalidateLayout() // if needed
        fpc.show()
    }
    
    //MARK: Delegate
    func floatingPanel(_ fpc: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        return MyFloatingPanelLayout()
    }
    
    func floatingPanelWillBeginDragging(_ fpc: FloatingPanelController) {
        viewModel.beforeNAfter = (fpc.state, viewModel.beforeNAfter.after)
        
        guard fpc.state == .half else { return }
        viewModel.zoomLevel = mapContainerView.currentZoomLevel
    }
    
    func isZoomInStation(isHidden: Bool) {
        guideView.isHidden = fpc.state == .hidden
        emptyView.isHidden = fpc.state == .hidden
        mapContainerView.setHidden(isHidden)
    }
    
    func floatingPanelDidChangeState(_ fpc: FloatingPanelController) {
        bottomAnimation(state: fpc.state)
        isZoomInStation(isHidden: fpc.state == .full)
        
        let halfHeight = view.safeAreaInsets.bottom + 180.0
        let fullHeight = view.safeAreaInsets.bottom + 450.0
        let bottomInset = fpc.state == .hidden ? .zero : fpc.state == .half ? halfHeight : fullHeight
        mapContainerView.setContentBottom(inset: bottomInset)
        
        switch fpc.state {
        case .hidden:
            mapContainerView.resetSelectedMarker()
        case .half:
            guard viewModel.beforeNAfter.before == .full else {
                return
            }
            let centerLocation = mapContainerView.currentMapCenterLocation
            mapContainerView.moveMap(
                scrollTo: centerLocation.coordinate,
                zoomTo: viewModel.zoomLevel,
                animation: .easeIn
            )
        case .full:
            if let station = viewModel.selectedStation {
                mapContainerView.moveMap(
                    scrollTo: station.coordinate.location.coordinate,
                    zoomTo: 15.0,
                    animation: .linear
                )
            }
            
            stationDetailInfoVC.requestStationDetail(id: viewModel.selectedStation?.stationID)
        default:
            break
        }
    }
}

//MARK: - List 관련
extension MainVC: MainListVCDelegate {
    func touchedCell(info: GasStationSummary) {
        mapContainerView.moveMarker(station: info)
    }
}

