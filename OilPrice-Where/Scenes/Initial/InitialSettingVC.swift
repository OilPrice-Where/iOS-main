//
//  InitialSettingVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 19.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Combine
import SnapKit


//MARK: 초기 설정 페이지
final class InitialSettingVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: InitialViewModel
    private let selectTypeView = SelectTypeView()
    
    
    //MARK: - Life Cycle
    init(viewModel: InitialViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindUI()
        bindActions()
    }
    
    //MARK: - Override Method
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    //MARK: - Set UI
    private func makeUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(selectTypeView)
        selectTypeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}


private extension InitialSettingVC {
    //MARK: - Rx Binging..
    func bindUI() {
        // 유종 타입 설정
        viewModel.fuelTypesPublisher
            .sink { [weak self] types in
                self?.selectTypeView.updateFuelTypeeSegments(with: types)
            }
            .store(in: &cancellable)
        // 네비게이션 타입 설정
        viewModel.navigationOptionsPublisher
            .sink { [weak self] options in
                self?.selectTypeView.updateNavigationOptionSegment(with: options)
            }
            .store(in: &cancellable)
    }
    
    func bindActions() {
        // 확인 버튼 클릭 이벤트
        let okActionPublisher = selectTypeView.okButton.tapPublisher
            .map { [weak self] _ -> InitialViewModel.UserSelection in
                guard let self else {
                    return InitialViewModel.UserSelection(
                        fuel: .gasoline,
                        navigation: .kakao
                    )
                }
                
                let fuelRawValue = selectTypeView.fuelTypeSegmentControl.selectedSegmentIndex
                let navigationRawValue = selectTypeView.naviTypeSegmentControl.selectedSegmentIndex
                
                return InitialViewModel.UserSelection(
                    fuel: InitialViewModel.FuelType(rawValue: fuelRawValue) ?? .gasoline,
                    navigation: InitialViewModel.NavigationService(rawValue: navigationRawValue) ?? .kakao
                )
            }
            .eraseToAnyPublisher()
        
        let output = viewModel.transform(input: .init(
            okActionPublisher: okActionPublisher
        ))
        
        // 메인으로 이동
        output.moveMain
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self else { return }
                
                let mainVC = MainVC()
                let mainNavigationVC = UINavigationController(rootViewController: mainVC)
                mainNavigationVC.modalPresentationStyle = .fullScreen
                mainVC.present(mainNavigationVC, animated: false)
            }
            .store(in: &viewModel.cancelBag)
    }
}
