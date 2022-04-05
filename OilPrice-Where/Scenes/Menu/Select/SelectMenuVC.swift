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

//MARK: SelectMenuVC
final class SelectMenuVC: UIViewController {
    enum SelectMenuType {
        case navigation
        case oilType
        case radius
    }
    
    //MARK: - Properties
    let bag = DisposeBag()
    let type: SelectMenuType
    let viewModel = SelectMenuViewModel()
    let containerView = UIView().then {
        $0.backgroundColor = .clear
    }
    let backgroundView = UIView().then {
        $0.alpha = 0.0
        $0.backgroundColor = .black
    }
    let selectMenuView = SelectMenuView()
    
    //MARK: - Life Cycle
    init(type: SelectMenuType) {
        self.type = type
        
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
                if title == self.viewModel.fetchSelect(type: self.type) {
                    self.selectMenuView.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
                }
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
                owner.viewModel.fetchUpdated(type: owner.type, title: title)
                owner.dismiss(animated: false)
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
        
        viewModel.input.fetchType.accept(type)
    }
    
    func fetchSelectMenuHeight() -> CGFloat {
        return 200 + fetchCollectionViewHeight()
    }
    
    func fetchCollectionViewHeight() -> CGFloat {
        switch type {
        case .navigation, .oilType:
            return 272.0
        case .radius:
            return 198.0
        }
    }
}
