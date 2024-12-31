//
//  MenuVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


final class MenuVC: CommonViewController {
    //MARK: - Properties
    let viewModel: MenuViewModel
    
    private let navigationView = MenuKeyValueView(title: "내비게이션", menuType: .keyValue)
    private let oilTypeView = MenuKeyValueView(title: "유종", menuType: .keyValue)
    private let historyView = MenuKeyValueView(title: "방문 내역", menuType: .key)
    private let findBrandView = MenuKeyValueView(title: "검색 브랜드", menuType: .key)
    private let avgView = MenuKeyValueView(title: "전국 평균가", menuType: .key)
    private let cardSaleView = MenuKeyValueView(title: "카드 할인", menuType: .key)
    private let aboutView = MenuKeyValueView(title: "About us", menuType: .subType)
    private let reviewView = MenuKeyValueView(title: "App 평가하기", menuType: .subType)
    private let versionView = MenuKeyValueView(title: "버전 정보", menuType: .subType)
    
    
    //MARK: - Life Cycle
    init(viewModel: MenuViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
}


//MARK: - Binding..
private extension MenuVC {
    func bindActions() {
        let selectedMenu: AnyPublisher<MenuViewModel.MenuType, Never> = Publishers.MergeMany(
            navigationView.gesturePublisher().map { _ in .navigation }.eraseToAnyPublisher(),
            oilTypeView.gesturePublisher().map { _ in .fuelType }.eraseToAnyPublisher(),
            historyView.gesturePublisher().map { _ in .history }.eraseToAnyPublisher(),
            avgView.gesturePublisher().map { _ in .priceAverage }.eraseToAnyPublisher(),
            findBrandView.gesturePublisher().map { _ in .searchBrand }.eraseToAnyPublisher(),
            cardSaleView.gesturePublisher().map { _ in .cardSale }.eraseToAnyPublisher(),
            aboutView.gesturePublisher().map { _ in .aboutUs }.eraseToAnyPublisher(),
            reviewView.gesturePublisher().map { _ in .editReview }.eraseToAnyPublisher(),
            versionView.gesturePublisher().map { _ in .checkVersion }.eraseToAnyPublisher()
        ).eraseToAnyPublisher()
        
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            selectedMenu: selectedMenu
        ))
        // 선택한 유종 타이틀 설정
        output.updateSavedFuelTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fuelType in
                self?.oilTypeView.valueLabel.text = fuelType
            }
            .store(in: &cancellable)
        // 선택한 내비게이션 타이틀 설정
        output.updateSavedNavigationTitle
            .receive(on: DispatchQueue.main)
            .sink { [weak self] navigation in
                self?.navigationView.valueLabel.text = navigation
            }
            .store(in: &cancellable)
        // 메뉴 VC 이동
        output.presentViewController
            .receive(on: DispatchQueue.main)
            .sink { [weak self] present in
                self?.present(present.viewController, animated: present.animated)
            }
            .store(in: &cancellable)
        // 앱 리뷰 작성
        output.openReview
            .receive(on: DispatchQueue.main)
            .sink { reviewURL in
                // 유효한 URL인지 검사
                guard UIApplication.shared.canOpenURL(reviewURL) else {
                    return
                }
                UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
            }
            .store(in: &cancellable)
        // 버전 확인
        output.showVersionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] versionStatus in
                self?.showVersionCheckAlertViewController(versionStatus: versionStatus)
            }
            .store(in: &cancellable)
    }
    
    func showVersionCheckAlertViewController(versionStatus: AppUpdateStatus) {
        let alert: UIAlertController
        
        switch versionStatus {
        case .upToDate(let title, let message):
            alert = UIAlertController.createAlertContoller(
                title: title,
                message: message
            )
            
        case .optionalUpdate(let title, let message, let appURLString):
            let nextUpdateAction = UIAlertAction(title: "나중에 하기", style: .destructive)
            let updateAction = UIAlertAction(title: "지금 업데이트 하기", style: .default) { _ in
                guard let appURL = URL(string: appURLString, encodingInvalidCharacters: false),
                      UIApplication.shared.canOpenURL(appURL) else {
                    return
                }
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            
            alert = UIAlertController.createAlertContoller(
                title: title,
                message: message,
                actions: [nextUpdateAction, updateAction]
            )
            
        case .forcedUpdate(let title, let message, let appURLString):
            let updateAction = UIAlertAction(title: "업데이트 하기", style: .default) { _ in
                guard let appURL = URL(string: appURLString, encodingInvalidCharacters: false),
                      UIApplication.shared.canOpenURL(appURL) else {
                    return
                }
                UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
            }
            
            alert = UIAlertController.createAlertContoller(
                title: title,
                message: message,
                actions: [updateAction]
            )
            
        case .versionInfoUnavailable(let title, let message):
            alert = UIAlertController.createAlertContoller(
                title: title,
                message: message
            )
        }
        
        present(alert, animated: true)
    }
}


//MARK: - Set UI
private extension MenuVC {
    enum UIConstants {
        enum OilTypeView {
            static let topOffset: CGFloat = 44
        }
        
        enum NavigationView {
            static let topOffset: CGFloat = 18
        }
        
        enum HistoryView {
            static let topOffset: CGFloat = 40
        }
        
        enum FindBrandView {
            static let topOffset: CGFloat = 18
        }
        
        enum AvgView {
            static let topOffset: CGFloat = 18
        }
        
        enum VersionView {
            static let bottomOffset: CGFloat = -40
        }
    }

    
    func makeUI() {
        view.backgroundColor = .white
        
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.addSubview(oilTypeView)
        view.addSubview(navigationView)
        view.addSubview(historyView)
        view.addSubview(findBrandView)
        view.addSubview(avgView)
//        view.addSubview(cardSaleView)
        view.addSubview(aboutView)
        view.addSubview(reviewView)
        view.addSubview(versionView)
    }
    
    func setConstraints() {
        oilTypeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.OilTypeView.topOffset)
            $0.left.right.equalToSuperview()
        }
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(oilTypeView.snp.bottom).offset(UIConstants.NavigationView.topOffset)
            $0.left.right.equalToSuperview()
        }
        
        historyView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(UIConstants.HistoryView.topOffset)
            $0.left.right.equalToSuperview()
        }
        
        findBrandView.snp.makeConstraints {
            $0.top.equalTo(historyView.snp.bottom).offset(UIConstants.FindBrandView.topOffset)
            $0.left.right.equalToSuperview()
        }
        
        avgView.snp.makeConstraints {
            $0.top.equalTo(findBrandView.snp.bottom).offset(UIConstants.AvgView.topOffset)
            $0.left.right.equalToSuperview()
        }
        
//        cardSaleView.snp.makeConstraints {
//            $0.top.equalTo(avgView.snp.bottom).offset(40)
//            $0.left.right.equalToSuperview()
//        }
        
        versionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.VersionView.bottomOffset)
            $0.left.right.equalToSuperview()
        }
        
        reviewView.snp.makeConstraints {
            $0.bottom.equalTo(versionView.snp.top)
            $0.left.right.equalToSuperview()
        }
        
        aboutView.snp.makeConstraints {
            $0.bottom.equalTo(reviewView.snp.top)
            $0.left.right.equalToSuperview()
        }
    }
}
