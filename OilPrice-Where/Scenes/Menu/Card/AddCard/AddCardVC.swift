//
//  AddCardVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/06/26.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

//MARK: 카드 추가 VC
final class AddCardVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        EditCardNameTableViewCell.register($0)
        CardBenefitTableViewCell.register($0)
        SelectedBrandTableViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.presentationController?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        navigationController?.presentationController?.delegate = nil
    }
    
    
    //MARK: - Make UI
    func makeUI() {
        isModalInPresentation = true
        let backButton = UIBarButtonItem(title: "취소", style: .plain, target: self, action: #selector(backButtonTapped))
        let saveButton = UIBarButtonItem(title: "저장", style: .plain, target: self, action: #selector(saveButtonTapped))
        
        navigationItem.title = "카드 추가"
        navigationItem.leftBarButtonItem = backButton
        navigationItem.rightBarButtonItem = saveButton
        
        view.backgroundColor = .white
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
//        nameTextField.resignFirstResponder()
    }
    
    func presentAlert() {
        let alert = UIAlertController(title: "알림", message: "카드를 저장하지 않고 닫으시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .destructive) { [weak self] _ in
            self?.navigationController?.popViewController(animated: true)
        }
        let cancel = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancel)
        
        present(alert, animated: true)
    }
    
    @objc
    func backButtonTapped() {
        presentAlert()
    }
    
    @objc
    func saveButtonTapped() {
        
    }
}

extension AddCardVC: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidAttemptToDismiss(_ presentationController: UIPresentationController) {
        presentAlert()
    }
}

extension AddCardVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withType: EditCardNameTableViewCell.self, for: indexPath)
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withType: CardBenefitTableViewCell.self, for: indexPath)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withType: SelectedBrandTableViewCell.self, for: indexPath)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.row {
        case 0:
            return 77.0
        case 1:
            return 171
        default:
            return 300
        }
    }
}
