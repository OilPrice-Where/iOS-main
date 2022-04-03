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

//MARK: MenuVC
final class MenuVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
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
        viewModel
            .output
            .fetchNavigationTitle()
            .bind(to: navigationView.valueLabel.rx.text)
            .disposed(by: bag)
        viewModel
            .output
            .fetchOilTypeString()
            .bind(to: oilTypeView.valueLabel.rx.text)
            .disposed(by: bag)
        viewModel
            .output
            .fetchDistanceString()
            .bind(to: radiusView.valueLabel.rx.text)
            .disposed(by: bag)
    }
}
