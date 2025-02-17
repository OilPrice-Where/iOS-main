//
//  MainVC.swift
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
import SideMenu
import FloatingPanel


//MARK: Main Map VC
final class MainVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: MainViewModel
    
    private let searchBarPublisher: PassthroughSubject<SearchPOI, Never> = .init()
    private let searchMapPublisher: PassthroughSubject<CLLocation, Never> = .init()
    private let selectedStationPublisher: PassthroughSubject<GasStationSummary, Never> = .init()
    
    /// MapView
    private let mapView = MainMapView()
    /// 사이드 메뉴
    private let sideMenu: SideMenuNavigationController
    /// 바텀시트
    private let bottomSheetController = FloatingPanelController()
    /// 주유소 상세 정보
    private let stationDetailInfoVC: StationInfoVC
    /// 선택된 주유소 액션 버튼 Container(`즐겨찾기`, `길 찾기`)
    private let stationActionsView = StationActionsView()
    
    private var bottomOffset: CGFloat = 36
    private let emptyView = UIView().then {
        $0.backgroundColor = .white
    }
    
    
    //MARK: - Life Cycle
    init(viewModel: MainViewModel,
         menuViewModel: MenuViewModel,
         stationInfoViewModel: StationInfoViewModel) {
        self.viewModel = viewModel
        self.stationDetailInfoVC = StationInfoVC(viewModel: stationInfoViewModel)
        let menuVC = MenuVC(viewModel: menuViewModel)
        self.sideMenu = SideMenuNavigationController(rootViewController: menuVC)
 
        super.init(nibName: nil, bundle: nil)
        
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindActions()
        //TODO: appVersionCheck()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        sideMenu.dismiss(animated: false)
    }
    
    override func setNetworkSetting() {
        super.setNetworkSetting()
        
        reachability?.whenReachable = { [weak self] _ in
//            self?.viewModel.input.requestStaions.send(nil)
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            //TODO: Check
//            self?.notConnect()
//            self?.viewModel.requestLocation = nil
            LocationManager.shared.currentLocation = nil
            self?.mapView.reset()
            self?.bottomSheetController.move(to: .hidden, animated: false, completion: nil)
        }
    }
    
    private func configure() {
        let searchPathRepository = TMapSearchPathRepository()
        LocationManager.shared.setLocationManager(searchPathRepository: searchPathRepository)
        mapView.delegate = self
    }
}


//MARK: - BindActions
private extension MainVC {
    func bindActions() {
        let settingsPublishers = SettingType.allCases
            .filter { $0 != .favorites }
            .map(\.notificationName)
            .map {
                return NotificationCenter.default
                    .publisher(for: $0)
                    .map { _ in }
                    .eraseToAnyPublisher()
            }
        
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            searchByPOI: searchBarPublisher.eraseToAnyPublisher(),
            searchByMap: searchMapPublisher.eraseToAnyPublisher(),
            updatedSettings: Publishers.MergeMany(settingsPublishers).eraseToAnyPublisher(),
            selectedStation: selectedStationPublisher.eraseToAnyPublisher()
        ))
        
        // favoriteButton Tapped
        stationActionsView.favoriteButton
            .tapPublisher
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.touchedFavoriteButton()
            }
            .store(in: &cancellable)
        
        // directionButton Tapped
        stationActionsView.directionButton
            .tapPublisher
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.toNavigationTapped()
            }
            .store(in: &cancellable)
        
        bindUI(output: output)
    }
    
    
    func bindUI(output: MainViewModel.Output) {
        output.staionsResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] staions in
                guard let self else { return }
                
                sideMenu.dismiss(animated: false)
                
                bottomSheetController.move(to: .hidden, animated: false) {
                    self.mapView.hideResearchButtonWithAnimation()
                }
                
                mapView.reset()
                mapView.applyCircle(coordinateSystem: viewModel.requestCoordinateSystem)
                mapView.showMarker(list: viewModel.stations)
                mapView.hideResearchButtonWithAnimation()
            }
            .store(in: &cancellable)
        // 즐겨찾기 목록의 StationID 값과 StationView의 StationID값이 동일 하면 선택 상태로 변경
        output.selectedStation
            .receive(on: DispatchQueue.main)
            .sink { [weak self] station in
                guard let self else { return }
                
                updateFavoriteUI()
                stationDetailInfoVC.configure(station: station)
                stationActionsView.configureDirectionButton(station: station)
            }
            .store(in: &cancellable)
    }
    
    
    func updateFavoriteUI() {
        let ids = DefaultData.shared.favoriteSubject.value
        
        guard let id = viewModel.selectedStation?.stationID else { return }
        let image = ids.contains(id) ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        DispatchQueue.main.async { [weak self] in
            self?.stationActionsView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            self?.stationActionsView.favoriteButton.imageView?.tintColor = ids.contains(id) ? .white : Asset.Colors.mainColor.color
            self?.stationActionsView.favoriteButton.backgroundColor = ids.contains(id) ? Asset.Colors.mainColor.color : .white
        }
    }
    
    func touchedFavoriteButton() {
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = viewModel.selectedStation?.stationID, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
        
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                //TODO: Check
//                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
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
}


//MARK: - SearchBarDelegate
extension MainVC: SearchBarDelegate {
    func search(poi: SearchPOI) {
        searchBarPublisher.send(poi)
        mapView.moveSearch(poi: poi)
    }
}


//MARK: - MainMapViewDelegate
extension MainVC: MainMapViewDelegate {
    func mapView(_ mapView: MainMapView, didTapMarker station: GasStationSummary) {
        if bottomSheetController.state == .hidden {
            bottomSheetController.move(to: .half, animated: true, completion: nil)
        }
        selectedStationPublisher.send(station)
    }
    
    func mapViewDidTapMap(_ mapView: MainMapView) {
        guard bottomSheetController.state != .hidden else { return }
        viewModel.beforeNAfter.before = .hidden
        bottomSheetController.move(to: .hidden, animated: true, completion: nil)
    }
    
    func mapViewDidTapFavorite(_ mapView: MainMapView) {
        let tabbar = FavoriteTabbarController()
        navigationController?.pushViewController(tabbar, animated: true)
    }
    
    func mapViewDidTapResearch(_ mapView: MainMapView) {
        searchMapPublisher.send(mapView.currentMapCenterLocation)
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
    //MARK: Delegate
    func floatingPanel(_ bottomSheetController: FloatingPanelController, layoutFor size: CGSize) -> FloatingPanelLayout {
        return MyFloatingPanelLayout()
    }
    
    func floatingPanelWillBeginDragging(_ bottomSheetController: FloatingPanelController) {
        viewModel.beforeNAfter = (bottomSheetController.state, viewModel.beforeNAfter.after)
        guard bottomSheetController.state == .half else { return }
        viewModel.location = mapView.currentMapCenterLocation
        viewModel.zoomLevel = mapView.currentZoomLevel
    }
    
    func isZoomInStation(isHidden: Bool) {
        stationActionsView.isHidden = bottomSheetController.state == .hidden
        emptyView.isHidden = bottomSheetController.state == .hidden
        mapView.setHidden(isHidden)
    }
    
    func floatingPanelDidChangeState(_ bottomSheetController: FloatingPanelController) {
        bottomAnimation(state: bottomSheetController.state)
        isZoomInStation(isHidden: bottomSheetController.state == .full)
        
        let halfHeight = view.safeAreaInsets.bottom + 180.0
        let fullHeight = view.safeAreaInsets.bottom + 450.0
        let bottomInset = bottomSheetController.state == .hidden ? .zero : bottomSheetController.state == .half ? halfHeight : fullHeight
        mapView.setContentBottom(inset: bottomInset)
        
        switch bottomSheetController.state {
        case .hidden:
            mapView.resetSelectedMarker()
        case .half:
            guard viewModel.beforeNAfter.before == .full else {
                return
            }
            if let centerLocation = viewModel.location {
                mapView.moveMap(
                    scrollTo: centerLocation.coordinate,
                    zoomTo: viewModel.zoomLevel,
                    animation: .easeIn
                )
            }
        case .full:
            if let station = viewModel.selectedStation {
                mapView.moveMap(
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
    
    private func bottomAnimation(state: FloatingPanelState) {
        guard (state == .hidden && bottomOffset != 36.0) ||
                ((state == .half || state == .full) && bottomOffset != 192.0) else { return }
        
        bottomOffset = state == .hidden ? 36.0 : 192.0
        let resultBottomOffset = bottomOffset + view.safeAreaInsets.bottom
        
        mapView.updatePostionBottomButtons(bottomOffset: resultBottomOffset)
    }
}

//MARK: - MainListVCDelegate
extension MainVC: MainListVCDelegate {
    func touchedCell(info: GasStationSummary) {
        mapView(mapView, didTapMarker: info)
        mapView.moveMarker(station: info)
    }
}


//MARK: - Set UI
private extension MainVC {
    enum UIConstants {
        enum Navigation {
            static let title: String = "주유 정보"
        }
        
        enum SideMenu {
            static let presentingEndAlpha = 0.65
            static let width = UIDevice.current.userInterfaceIdiom == .pad ? 328.0 : UIScreen.screenWidth * (240 / 375)
        }
        
        enum StationActionView {
            static let height: CGFloat = 82
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func updateUI() {
        navigationController?.navigationBar.isHidden = true
        UIApplication.shared.statusBarUIView?.backgroundColor = .clear
    }
    
    func configureUI() {
        navigationItem.title = UIConstants.Navigation.title
        view.backgroundColor = .white
        view.addSubview(mapView)
        
        configureMenu()
        configureBottomSheet()
    }
    
    func configureMenu() {
        sideMenu.leftSide = true
        sideMenu.settings = {
            var settings = SideMenuSettings()
            settings.statusBarEndAlpha = .zero
            settings.presentationStyle = SideMenuPresentationStyle.menuSlideIn
            settings.presentationStyle.presentingEndAlpha = UIConstants.SideMenu.presentingEndAlpha
            settings.menuWidth = UIConstants.SideMenu.width
            settings.blurEffectStyle = nil
            return settings
        }()
    }
    
    func configureBottomSheet() {
        bottomSheetController.view.addSubview(stationActionsView)
        bottomSheetController.view.addSubview(emptyView)
        
        bottomSheetController.contentMode = .fitToBounds
        bottomSheetController.changePanelStyle() // panel 스타일 변경 (대신 bar UI가 사라지므로 따로 넣어주어야함)
        bottomSheetController.delegate = self
        bottomSheetController.set(contentViewController: stationDetailInfoVC) // floating panel에 삽입할 것
        bottomSheetController.addPanel(toParent: self) // bottomSheetController를 관리하는 UIViewController
        bottomSheetController.layout = MyFloatingPanelLayout()
        bottomSheetController.invalidateLayout() // if needed
        bottomSheetController.show()
    }
    
    func setConstraints() {
        mapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        stationActionsView.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(UIConstants.StationActionView.height)
        }
        emptyView.snp.makeConstraints {
            $0.top.equalTo(stationActionsView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
