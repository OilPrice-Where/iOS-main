//
//  InitialSettingVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 19.
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

// 초기 설정 페이지
class InitialSettingVC: CommonViewController {
    typealias selectTypes = (oil: Int, navi: Int)
    
    var viewModel: InitialViewModel!
    let selectTypeView = SelectTypeView()
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
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
    
    //MARK: - View Binging..
    func bindViewModel() {
        // 확인 버튼 클릭 이벤트
        selectTypeView.okButton
            .rx
            .tap
            .map { [weak self] _ -> selectTypes in
                guard let strongSelf = self else { return (oil: 0, navi: 0) }
                
                let oilIdx = strongSelf.selectTypeView.oilTypeSegmentControl.selectedSegmentIndex
                let naviIdx = strongSelf.selectTypeView.naviTypeSegmentControl.selectedSegmentIndex
                
                return (oil: oilIdx, navi: naviIdx)
            }
            .do(onNext: { selectTypes in
                self.viewModel.okAction(oil: selectTypes.oil, navi: selectTypes.navi)
            })
            .bind(with: self, onNext: { owner, _ in
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "TabBarController")
                
                owner.present(vc, animated: false)
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Configure UI
    func makeUI() {
        view.addSubview(selectTypeView)
        
        selectTypeView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
}
