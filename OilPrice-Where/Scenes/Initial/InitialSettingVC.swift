//
//  InitialSettingVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 19.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Combine
import CombineCocoa
import SnapKit
//MARK: 초기 설정 페이지
final class InitialSettingVC: CommonViewController {
    //MARK: - Properties
    typealias selectTypes = (oil: Int, navi: Int)
    var viewModel = InitialViewModel()
    private let selectTypeView = SelectTypeView()
    
    //MARK: - Life Cycle
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        view.backgroundColor = Asset.Colors.mainColor.color
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        bindViewModel()
        makeUI()
    }
    
    //MARK: - Override Method
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: - Rx Binging..
    func bindViewModel() {
        // 확인 버튼 클릭 이벤트
        selectTypeView.okButton
            .tapPublisher
            .map { [weak self] _ -> selectTypes in
                guard let owner = self else { return (oil: 0, navi: 0) }
                
                let oilIdx = owner.selectTypeView.oilTypeSegmentControl.selectedSegmentIndex
                let naviIdx = owner.selectTypeView.naviTypeSegmentControl.selectedSegmentIndex
                owner.viewModel.okAction(oil: oilIdx, navi: naviIdx)
                
                return (oil: oilIdx, navi: naviIdx)
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                
                let mainVC = MainVC()
                let mainNavigationVC = UINavigationController(rootViewController: mainVC)
                mainNavigationVC.modalPresentationStyle = .fullScreen
                owner.present(mainNavigationVC, animated: false)
            }
            .store(in: &viewModel.cancelBag)
    }
    
    //MARK: - Set UI
    private func makeUI() {
        view.addSubview(selectTypeView)
        
        selectTypeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
