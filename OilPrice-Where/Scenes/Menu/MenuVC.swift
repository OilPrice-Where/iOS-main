//
//  MenuVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import Combine
import Firebase
import Toast

//MARK: MenuVC
final class MenuVC: CommonViewController {
    //MARK: - Properties
    var ref: DatabaseReference?
    let viewModel = MenuViewModel()
    private lazy var navigationView = MenuKeyValueView(type: .keyValue).then {
        $0.keyLabel.text = "내비게이션"
    }
    private lazy var oilTypeView = MenuKeyValueView(type: .keyValue).then {
        $0.keyLabel.text = "유종"
    }
    private lazy var historyView = MenuKeyValueView(type: .key).then {
        $0.keyLabel.text = "방문 내역"
    }
    private lazy var findBrandView = MenuKeyValueView(type: .key).then {
        $0.keyLabel.text = "검색 브랜드"
    }
    private lazy var avgView = MenuKeyValueView(type: .key).then {
        $0.keyLabel.text = "전국 평균가"
    }
    private lazy var cardSaleView = MenuKeyValueView(type: .key).then {
        $0.keyLabel.text = "카드 할인"
    }
    private lazy var aboutView = MenuKeyValueView(type: .subType).then {
        $0.keyLabel.text = "About us"
    }
    private lazy var reviewView = MenuKeyValueView(type: .subType).then {
        $0.keyLabel.text = "App 평가하기"
    }
    private lazy var versionView = MenuKeyValueView(type: .subType).then {
        $0.keyLabel.text = "버전 정보"
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bind()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .white
        view.addSubview(oilTypeView)
        view.addSubview(navigationView)
        view.addSubview(historyView)
        view.addSubview(findBrandView)
        view.addSubview(avgView)
//        view.addSubview(cardSaleView)
        view.addSubview(aboutView)
        view.addSubview(reviewView)
        view.addSubview(versionView)
        
        oilTypeView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(44)
            $0.left.right.equalToSuperview()
        }
        navigationView.snp.makeConstraints {
            $0.top.equalTo(oilTypeView.snp.bottom).offset(18)
            $0.left.right.equalToSuperview()
        }
        historyView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview()
        }
        findBrandView.snp.makeConstraints {
            $0.top.equalTo(historyView.snp.bottom).offset(18)
            $0.left.right.equalToSuperview()
        }
        avgView.snp.makeConstraints {
            $0.top.equalTo(findBrandView.snp.bottom).offset(18)
            $0.left.right.equalToSuperview()
        }
//        cardSaleView.snp.makeConstraints {
//            $0.top.equalTo(avgView.snp.bottom).offset(40)
//            $0.left.right.equalToSuperview()
//        }
        versionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-40)
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
    
    //MARK: - Rx Binding..
    func bind() {
        DefaultData.shared.naviSubject
            .map { Preferences.navigation(type: $0) }
            .assign(to: \.text, on: navigationView.valueLabel)
            .store(in: &viewModel.cancellable)
        
        DefaultData.shared.oilSubject
            .map { Preferences.oil(code: $0) }
            .assign(to: \.text, on: oilTypeView.valueLabel)
            .store(in: &viewModel.cancellable)
                
        // 내비게이션
        navigationView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let vc = SelectMenuVC(type: .navigation)
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc, animated: false)
            }
            .store(in: &viewModel.cancellable)
        
        // 유종
        oilTypeView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let vc = SelectMenuVC(type: .oilType)
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc, animated: false)
            }
            .store(in: &viewModel.cancellable)
        
        // 방문 내역
        historyView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let navi = owner.viewModel.output.fetchNavigationController(type: .history)
                owner.present(navi, animated: true)
            }
            .store(in: &viewModel.cancellable)
        
        // 전국 평균가
        avgView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self else { return }
                
                let stationRepository: StationRepository = StationRepositoryImpl()
                let averageCostRepository: AverageCostRepository = FirebaseAverageCostRepository(stationRepository: stationRepository)
                let averageCostUseCase: AverageCostUseCase = AverageCostUseCaseImpl(averageCostRepository: averageCostRepository)
                let priceAverageViewModel = PriceAverageViewModel(averageCostUseCase: averageCostUseCase)
                let priceAverageVC = PriceAverageVC(viewModel: priceAverageViewModel)
                priceAverageVC.modalPresentationStyle = .overFullScreen
                present(priceAverageVC, animated: false)
            }
            .store(in: &viewModel.cancellable)
        
        // 검색 브랜드
        findBrandView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let navi = owner.viewModel.output.fetchNavigationController(type: .findBrand)
                owner.present(navi, animated: true)
            }
            .store(in: &viewModel.cancellable)
        
        // 카드 할인
        cardSaleView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let navi = owner.viewModel.output.fetchNavigationController(type: .cardSale)
                owner.present(navi, animated: true)
            }
            .store(in: &viewModel.cancellable)
        
        // AboutUs
        aboutView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                let navi = owner.viewModel.output.fetchNavigationController(type: .aboutUs)
                owner.present(navi, animated: true)
            }
            .store(in: &viewModel.cancellable)
        
        // 리뷰 작성
        reviewView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.viewModel.output.fetchReview()
            }
            .store(in: &viewModel.cancellable)
        
        // 버전 확인
        versionView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self, let infoDic = Bundle.main.infoDictionary,
                      let currentVersion = infoDic["CFBundleShortVersionString"] as? String else {
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    let alert = UIAlertController(title: "현재 사용 중인 버전", message: "최신 버전: \(currentVersion ?? "")", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(okAction)
                    
                    self?.present(alert, animated: true)
                    
                    return
                }
                
                owner.versionCheck { lastestVersion in
                    if currentVersion != lastestVersion {
                        let alert = UIAlertController(title: "최신 버전이 있습니다.", message: "설치된 버전: \(currentVersion)\n최신 버전: \(lastestVersion)", preferredStyle: .alert)
                        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
                            let id = "1435350344"
                            if let appURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)"),
                               UIApplication.shared.canOpenURL(appURL) {
                                // 유효한 URL인지 검사
                                if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                                    UIApplication.shared.open(appURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(appURL)
                                }
                            }
                        }
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        
                        alert.addAction(okAction)
                        alert.addAction(updateAction)
                        owner.present(alert, animated: true)
                    } else {
                        let alert = UIAlertController(title: "최신 버전을 사용 중입니다.", message: "설치된 버전: \(currentVersion)\n최신 버전: \(lastestVersion)", preferredStyle: .alert)
                        
                        let okAction = UIAlertAction(title: "확인", style: .default)
                        alert.addAction(okAction)
                        
                        owner.present(alert, animated: true)
                    }
                }
            }
            .store(in: &viewModel.cancellable)
    }
    
    func configure() {
        ref = Database.database().reference()
    }
    
    func versionCheck(completion: @escaping (String) -> ()) {
        guard let _ref = ref else { return }
        
        let data = _ref.child("version").child("lastest_version_name")
        
        data.observeSingleEvent(of: .value) { snapshot in
            guard let lastest_version_name = snapshot.value as? String else { return }
            
            completion(lastest_version_name)
        }
    }
}
