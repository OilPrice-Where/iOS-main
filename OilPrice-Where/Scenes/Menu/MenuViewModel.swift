//
//  MenuViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine


final class MenuViewModel {
    //MARK: - Properties
    var appVersionUseCase: AppVersionUseCase
    
    
    init(appVersionUseCase: AppVersionUseCase) {
        self.appVersionUseCase = appVersionUseCase
    }
}


extension MenuViewModel {
    enum MenuType {
        case navigation
        case fuelType
        case history
        case priceAverage
        case searchBrand
        case cardSale
        case aboutUs
        case editReview
        case checkVersion
    }
    
    struct PresentMenu {
        let viewController: UIViewController
        let animated: Bool
    }
    
    struct Input {
        /// 메뉴 선택
        var selectedMenu: AnyPublisher<MenuType, Never>
    }
    
    struct Output {
        /// 메뉴 VC 이동
        var presentViewController: AnyPublisher<PresentMenu, Never>
        /// 앱 리뷰 작성
        var openReview: AnyPublisher<URL, Never>
        /// 버전 확인
        var showVersionStatus: AnyPublisher<AppUpdateStatus, Never>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            presentViewController: presentViewControllerPublisher(input: input),
            openReview: openReviewPublisher(input: input),
            showVersionStatus: showVersionStatusPublisher(input: input)
        )
    }
}


//MARK: - Make Publisher
private extension MenuViewModel {
    func presentViewControllerPublisher(input: Input) -> AnyPublisher<PresentMenu, Never> {
        return input.selectedMenu
            .flatMap { [weak self] menu -> AnyPublisher<PresentMenu, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                
                switch menu {
                case .navigation:
                    return selectMenuViewController(type: .navigation)
                case .fuelType:
                    return selectMenuViewController(type: .oilType)
                case .history:
                    return historiesViewController()
                case .priceAverage:
                    return priceAverageViewController()
                case .searchBrand:
                    return searchBrandViewController()
                case .cardSale:
                    return cardSaleViewController()
                case .aboutUs:
                    return aboutUsViewController()
                default:
                    return Empty().eraseToAnyPublisher()
                }
            }
            .eraseToAnyPublisher()
    }
    
    func openReviewPublisher(input: Input) -> AnyPublisher<URL, Never> {
        return input.selectedMenu
            .compactMap { menu in
                let appID = "1435350344"
                let appReviewURL = "itms-apps://itunes.apple.com/app/itunes-u/id\(appID)?ls=1&mt=8&action=write-review"
                
                guard
                    menu == .editReview,
                    let reviewURL = URL(string: appReviewURL, encodingInvalidCharacters: false)
                else {
                    return nil
                }
                
                return reviewURL
            }
            .eraseToAnyPublisher()
    }
    
    func showVersionStatusPublisher(input: Input) -> AnyPublisher<AppUpdateStatus, Never> {
        input.selectedMenu
            .filter { $0 == .checkVersion }
            .flatMap { [weak self] _ -> AnyPublisher<AppUpdateStatus, Never> in
                guard let self else {
                    return Empty().eraseToAnyPublisher()
                }
                return appUpdateStatusPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func appUpdateStatusPublisher() -> AnyPublisher<AppUpdateStatus, Never> {
        Deferred {
            Future { promise in
                Task { [weak self] in
                    guard let self else {
                        return
                    }
                    
                    let versionStauts = await appVersionUseCase.checkAndUpdateAppVersion()
                    promise(.success(versionStauts))
                }
            }
        }.eraseToAnyPublisher()
    }
}


//MARK: - Make VC
private extension MenuViewModel {
    /// 내비게이션 선택, 유종 선택 화면
    func selectMenuViewController(type: SelectMenuViewModel.SelectMenuType) -> AnyPublisher<PresentMenu, Never> {
        let selectMenuViewController = SelectMenuVC(type: type)
        selectMenuViewController.modalPresentationStyle = .overFullScreen
        
        return Just(PresentMenu(
            viewController: selectMenuViewController,
            animated: false
        )).eraseToAnyPublisher()
    }
    
    /// 방문 내역
    func historiesViewController() -> AnyPublisher<PresentMenu, Never> {
        let stationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
        let historiesViewModel = HistoriesViewModel(storage: stationStorage)
        let historiesVC = HistoriesVC(viewModel: historiesViewModel)
        
        return Just(PresentMenu(
            viewController: createStyledNavigationController(historiesVC),
            animated: true
        )).eraseToAnyPublisher()
    }
    
    /// 전국 평균가
    func priceAverageViewController() -> AnyPublisher<PresentMenu, Never> {
        let stationRepository: StationRepository = StationRepositoryImpl()
        let averageCostRepository: AverageCostRepository = FirebaseAverageCostRepository(stationRepository: stationRepository)
        let averageCostUseCase: AverageCostUseCase = AverageCostUseCaseImpl(averageCostRepository: averageCostRepository)
        let priceAverageViewModel = PriceAverageViewModel(averageCostUseCase: averageCostUseCase)
        let priceAverageVC = PriceAverageVC(viewModel: priceAverageViewModel)
        priceAverageVC.modalPresentationStyle = .overFullScreen
        
        return Just(PresentMenu(
            viewController: priceAverageVC,
            animated: false
        )).eraseToAnyPublisher()
    }
    
    /// 검색 브랜드
    func searchBrandViewController() -> AnyPublisher<PresentMenu, Never> {
        let storage: SettingStorage = PlistSettingStorage()
        let useCase: SettingUseCase = SettingUseCaseImpl(storage: storage)
        let viewModel: FindBrandViewModel = .init(settingUseCase: useCase)
        let brandVC: FindBrandVC = .init(viewModel: viewModel)
        
        return Just(PresentMenu(
            viewController: createStyledNavigationController(brandVC),
            animated: true
        )).eraseToAnyPublisher()
    }
    
    /// 카드 할인
    func cardSaleViewController() -> AnyPublisher<PresentMenu, Never> {
        let cardSaleVC = SettingEditSalePriceVC()
        
        return Just(PresentMenu(
            viewController: createStyledNavigationController(cardSaleVC),
            animated: true
        )).eraseToAnyPublisher()
    }
    
    /// About Us
    func aboutUsViewController() -> AnyPublisher<PresentMenu, Never> {
        let aboutViewModel = SettingAboutUsViewModel()
        let aboutVC = SettingAboutUsVC(viewModel: aboutViewModel)
        
        return Just(PresentMenu(
            viewController: createStyledNavigationController(aboutVC),
            animated: true
        )).eraseToAnyPublisher()
    }
    
    func createStyledNavigationController(_ viewController: UIViewController) -> UINavigationController {
        return UINavigationController(rootViewController: viewController).then {
            $0.navigationBar.tintColor = .white
            $0.navigationBar.titleTextAttributes = [
                .font: FontFamily.NanumSquareRound.bold.font(size: 17),
                .foregroundColor: UIColor.white
            ]
            $0.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        }
    }
}
