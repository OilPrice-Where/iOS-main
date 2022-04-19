//
//  SelectMenuVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

protocol SelectMenuVCDelegate: AnyObject {
    func dismissSelected(type: SelectMenuViewModel.SelectMenuType)
}

//MARK: SelectMenuVC
final class SelectMenuVC: CommonViewController {
    //MARK: - Properties
    let viewModel: SelectMenuViewModel
    weak var delegate: SelectMenuVCDelegate?
    let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    let backgroundView = UIView().then {
        $0.alpha = 0.0
        $0.backgroundColor = .black
    }
    let selectMenuView = SelectMenuView()
    
    //MARK: - Life Cycle
    init(type: SelectMenuViewModel.SelectMenuType) {
        viewModel = SelectMenuViewModel(type: type)
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.backgroundView.alpha = 0.65
            self?.selectMenuView.alpha = 1.0
        }
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .clear
        
        view.addSubview(containerView)
        containerView.addSubview(backgroundView)
        containerView.addSubview(selectMenuView)
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        selectMenuView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width * 0.8)
            $0.height.equalTo(fetchSelectMenuHeight())
        }
        selectMenuView.collectionView.snp.makeConstraints {
            $0.height.equalTo(fetchCollectionViewHeight())
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        viewModel
            .output
            .fetchModel
            .asDriver(onErrorJustReturn: [])
            .drive(selectMenuView.collectionView.rx.items(cellIdentifier: SelectMenuCollectionViewCell.id,
                                                          cellType: SelectMenuCollectionViewCell.self)) { index, title, cell in
                cell.titleLabel.text = title
            }
            .disposed(by: bag)
        viewModel
            .output
            .fetchTitle
            .asDriver(onErrorJustReturn: "")
            .drive(selectMenuView.titleLabel.rx.text)
            .disposed(by: bag)
        selectMenuView.laterButton
            .rx
            .tap
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: bag)
        selectMenuView.collectionView
            .rx
            .modelSelected(String.self)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, title in
                owner.viewModel.input.fetchUpdate.accept(title)
                owner.dismiss(animated: false) {
                    var msg = ""
                    
                    switch owner.viewModel.type {
                    case .navigation:
                        let navi = Preferences.navigation(type: DefaultData.shared.naviSubject.value)
                        let title = navi == "카카오맵" || navi == "티맵" ? "\(navi)으로" : "\(navi)로"
                        msg = "\(title) 길 안내를 제공합니다.\n메뉴에서 언제든 변경하실 수 있습니다."
                    case .oilType:
                        msg = "선택하신 유종으로 탐색을 시작합니다.\n메뉴에서 언제든 변경하실 수 있습니다."
                    case .radius:
                        msg = "선택하신 반경으로 탐색을 시작합니다.\n메뉴에서 언제든 변경하실 수 있습니다."
                    }
                    
                    UIApplication.shared.customKeyWindow?.hideToast()
                    let lbl = owner.showToast(width: 210, message: msg)
                    UIApplication.shared.customKeyWindow?.showToast(lbl, position: .top)
                }
            })
            .disposed(by: bag)
        backgroundView
            .rx
            .tapGesture()
            .when(.recognized)
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, _ in
                owner.dismiss(animated: false)
            })
            .disposed(by: bag)
        viewModel
            .output
            .fetchSelect
            .observe(on: MainScheduler.asyncInstance)
            .bind(with: self, onNext: { owner, idx in
                owner.selectMenuView.collectionView.selectItem(at: IndexPath(item: idx, section: 0), animated: false, scrollPosition: .top)
            })
            .disposed(by: bag)
        
        viewModel.input.fetchType.accept(nil)
    }
    
    func fetchSelectMenuHeight() -> CGFloat {
        return 200 + fetchCollectionViewHeight()
    }
    
    func fetchCollectionViewHeight() -> CGFloat {
        switch viewModel.type {
        case .navigation, .oilType:
            return 272.0
        case .radius:
            return 198.0
        }
    }
}