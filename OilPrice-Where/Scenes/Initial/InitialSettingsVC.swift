//
//  InitialSettingsVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 19.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Combine
import SnapKit


//MARK: 초기 설정 페이지
final class InitialSettingsVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: InitialSettingsViewModel
    private let initialSettingsView = InitialSettingsView()
    
    private let allSettingsSelectedPublisher = PassthroughSubject<InitialSettingsViewModel.SelectionResult, Never>()
    
    
    init(viewModel: InitialSettingsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configureInitialSettingsView()
        bindActions()
    }
}


private extension InitialSettingsVC {
    func bindActions() {
        let output = viewModel.transform(input: .init(
            allSettingsSelectedPublisher: allSettingsSelectedPublisher.eraseToAnyPublisher()
        ))
        // 메인으로 이동
        output.moveMain
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                
                let settingStorage: SettingStorage = PlistSettingStorage()
                let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
                let stationRepository: StationRepository = StationRepositoryImpl()
                let stationInfoViewModel: StationInfoViewModel = StationInfoViewModel(
                    settingUseCase: settingUseCase,
                    stationRepository: stationRepository
                )
                
                let appVersionRepository: AppVersionRepository = FirebaseAppVersionRepository()
                let appVersionUseCase: AppVersionUseCase = AppVersionUseCaseImpl(appVersionRepository: appVersionRepository)
                let menuViewModel = MenuViewModel(
                    settingUseCase: settingUseCase,
                    appVersionUseCase: appVersionUseCase
                )
                
                let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
                
                let mainViewModel = MainViewModel(
                    settingUseCase: settingUseCase,
                    stationRepository: stationRepository,
                    visitedStationStorage: visitedStationStorage)
                let mainVC = MainVC(
                    viewModel: mainViewModel,
                    menuViewModel: menuViewModel,
                    stationInfoViewModel: stationInfoViewModel)
                let mainNavigationVC = UINavigationController(rootViewController: mainVC)
                mainNavigationVC.modalPresentationStyle = .fullScreen
                present(mainNavigationVC, animated: false)
            }
            .store(in: &cancellable)
    }
}


//MARK: - Set UI
private extension InitialSettingsVC {
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(initialSettingsView)
    }
    
    func setConstraints() {
        initialSettingsView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}


extension InitialSettingsVC: InitialSettingsViewDelegate {
    func initialSettingsView(_ view: InitialSettingsView, didSelect selection: InitialSettingsViewModel.SelectionResult) {
        allSettingsSelectedPublisher.send(selection)
    }
    
    private func configureInitialSettingsView() {
        initialSettingsView.delegate = self
    }
}
