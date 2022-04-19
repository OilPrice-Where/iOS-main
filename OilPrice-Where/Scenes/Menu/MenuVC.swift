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
import RxSwift
import RxCocoa
import Firebase
import Toast_Swift

//MARK: MenuVC
final class MenuVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    var ref: DatabaseReference?
    let viewModel = MenuViewModel()
    private lazy var navigationView = MenuKeyValueView(type: .keyValue).then {
        $0.keyLabel.text = "내비게이션"
    }
    private lazy var oilTypeView = MenuKeyValueView(type: .keyValue).then {
        $0.keyLabel.text = "유종"
    }
    private lazy var radiusView = MenuKeyValueView(type: .keyValue).then {
        $0.keyLabel.text = "검색 반경"
    }
    private lazy var findBrandView = MenuKeyValueView(type: .key).then {
        $0.keyLabel.text = "검색 브랜드"
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
        rxBind()
        configure()
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .white
        view.addSubview(navigationView)
        view.addSubview(oilTypeView)
        view.addSubview(radiusView)
        view.addSubview(findBrandView)
        view.addSubview(cardSaleView)
        view.addSubview(aboutView)
        view.addSubview(reviewView)
        view.addSubview(versionView)
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(14)
            $0.left.right.equalToSuperview()
        }
        oilTypeView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(42)
            $0.left.right.equalToSuperview()
        }
        radiusView.snp.makeConstraints {
            $0.top.equalTo(oilTypeView.snp.bottom).offset(18)
            $0.left.right.equalToSuperview()
        }
        findBrandView.snp.makeConstraints {
            $0.top.equalTo(radiusView.snp.bottom).offset(40)
            $0.left.right.equalToSuperview()
        }
        cardSaleView.snp.makeConstraints {
            $0.top.equalTo(findBrandView.snp.bottom).offset(18)
            $0.left.right.equalToSuperview()
        }
        versionView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-48)
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
    func rxBind() {
        DefaultData.shared.naviSubject
            .map { Preferences.navigation(type: $0) }
            .asDriver(onErrorJustReturn: "")
            .drive(navigationView.valueLabel.rx.text)
            .disposed(by: bag)
        DefaultData.shared.oilSubject
            .map { Preferences.oil(code: $0) }
            .asDriver(onErrorJustReturn: "")
            .drive(oilTypeView.valueLabel.rx.text)
            .disposed(by: bag)
        DefaultData.shared.radiusSubject
            .map { String($0 / 1000) + "KM" }
            .asDriver(onErrorJustReturn: "")
            .drive(radiusView.valueLabel.rx.text)
            .disposed(by: bag)
        // 내비게이션
        navigationView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let vc = SelectMenuVC(type: .navigation)
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc, animated: false)
            })
            .disposed(by: bag)
        // 유종
        oilTypeView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let vc = SelectMenuVC(type: .oilType)
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc, animated: false)
            })
            .disposed(by: bag)
        // 검색 반경
        radiusView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let vc = SelectMenuVC(type: .radius)
                vc.modalPresentationStyle = .overFullScreen
                owner.present(vc, animated: false)
            })
            .disposed(by: bag)
        // 검색 브랜드
        findBrandView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let navi = owner.viewModel.output.fetchNavigationController(type: .findBrand)
                owner.present(navi, animated: true)
            })
            .disposed(by: bag)
        // 카드 할인
        cardSaleView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let navi = owner.viewModel.output.fetchNavigationController(type: .cardSale)
                owner.present(navi, animated: true)
            })
            .disposed(by: bag)
        // AboutUs
        aboutView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                let navi = owner.viewModel.output.fetchNavigationController(type: .aboutUs)
                owner.present(navi, animated: true)
            })
            .disposed(by: bag)
        // 리뷰 작성
        reviewView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.viewModel.output.fetchReview()
            })
            .disposed(by: bag)
        // 버전 확인
        versionView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                guard let infoDic = Bundle.main.infoDictionary,
                      let currentVersion = infoDic["CFBundleShortVersionString"] as? String else {
                    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    let alert = UIAlertController(title: "현재 사용 중인 버전", message: "최신 버전: \(currentVersion ?? "")", preferredStyle: .alert)
                    
                    let okAction = UIAlertAction(title: "확인", style: .default)
                    alert.addAction(okAction)
                    
                    owner.present(alert, animated: true)
                    
                    return
                }
                
                owner.versionCheck { lastestVersion in
                    if currentVersion != lastestVersion {
                        let alert = UIAlertController(title: "최신 버전이 있습니다.", message: "설치된 버전: \(currentVersion)\n최신 버전: \(lastestVersion)", preferredStyle: .alert)
                        let updateAction = UIAlertAction(title: "업데이트", style: .default) { _ in
                            let id = "1435350344"
                            if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)"),
                               UIApplication.shared.canOpenURL(reviewURL) {
                                // 유효한 URL인지 검사
                                if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                                } else {
                                    UIApplication.shared.openURL(reviewURL)
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
            })
            .disposed(by: bag)
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
