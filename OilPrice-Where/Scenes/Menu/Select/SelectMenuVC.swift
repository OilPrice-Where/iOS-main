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
import Combine
import CombineCocoa
import CombineDataSources

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
            .bind(subscriber: selectMenuView.collectionView.itemsSubscriber(cellIdentifier: SelectMenuCollectionViewCell.id,
                                                                            cellType: SelectMenuCollectionViewCell.self,
                                                                            cellConfig: { cell, indexPath, title in
                cell.titleLabel.text = title
            }))
            .store(in: &viewModel.cancelBag)
        
        viewModel
            .output
            .fetchTitle
            .compactMap { $0 }
            .assign(to: \.text, on: selectMenuView.titleLabel)
            .store(in: &viewModel.cancelBag)
        
        selectMenuView.laterButton
            .tapPublisher
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.dismiss(animated: false)
            }
            .store(in: &viewModel.cancelBag)
        
        selectMenuView.collectionView
            .didSelectItemPublisher
            .map { [weak self] indexPath in
                self?.selectMenuView.collectionView.cellForItem(at: indexPath) as? SelectMenuCollectionViewCell
            }
            .compactMap { $0?.titleLabel.text }
            .sink { [weak self] title in
                guard let owner = self else { return }
                
                owner.viewModel.input.fetchUpdate.send(title)
                owner.dismiss(animated: false) {
                    var msg = ""
                    var subTitle = "메뉴에서 언제든 변경하실 수 있습니다."
                    var installURL: URL? = nil
                    
                    switch owner.viewModel.type {
                    case .navigation:
                        let resultURL = owner.requestURL(station: nil)
                        let isInstallation = resultURL.isCanOpen
                        
                        let navi = Preferences.navigation(type: DefaultData.shared.naviSubject.value)
                        let title = navi == "카카오맵" || navi == "티맵" ? "\(navi)으로" : "\(navi)로"
                        
                        if !isInstallation {
                            installURL = resultURL.requestURL
                            subTitle = navi == "카카오맵" || navi == "티맵" ? "\(navi)이" : "\(navi)가"
                            subTitle += " 설치되어 있지 않아 설치페이지로 이동합니다."
                        }

                        msg = "\(title) 길 안내를 제공합니다.\n\(subTitle)"
                    case .oilType:
                        msg = "선택하신 유종으로 탐색을 시작합니다.\n\(subTitle)"
                    case .background:
                        msg = "백그라운드 탐색을 \(DefaultData.shared.backgroundFindSubject.value ? "시작합니다" : "끕니다").\n\(subTitle)"
                    }
                    
                    UIApplication.shared.customKeyWindow?.hideToast()
                    let lbl = Preferences.showToast(width: subTitle == "메뉴에서 언제든 변경하실 수 있습니다." ? 210 : 290, message: msg, subTitle: subTitle)
                    UIApplication.shared.customKeyWindow?.showToast(lbl, duration: 2.0, position: .top, completion: { _ in
                        guard let installURL = installURL else { return }
                        UIApplication.shared.open(installURL)
                    })
                }
            }
            .store(in: &viewModel.cancelBag)
        
        backgroundView
            .gesture()
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.dismiss(animated: false)
            }
            .store(in: &viewModel.cancelBag)
        
        viewModel
            .output
            .fetchSelect
            .sink { [weak self] idx in
                guard let owner = self else { return }
                owner.selectMenuView.collectionView.selectItem(at: IndexPath(item: idx, section: 0), animated: false, scrollPosition: .top)
            }
            .store(in: &viewModel.cancelBag)
        
        viewModel.input.fetchType.send(nil)
    }
    
    func fetchSelectMenuHeight() -> CGFloat {
        return 200 + fetchCollectionViewHeight()
    }
    
    func fetchCollectionViewHeight() -> CGFloat {
        switch viewModel.type {
        case .navigation, .oilType:
            return 272.0
        case .background:
            return 128.0
        }
    }
}
