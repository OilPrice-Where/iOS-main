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
    var viewModel = FindBrandViewModel()
    private var isAllSwitchButton = PublishSubject<Bool>()
    private var isLauchSetting = false
    let items = ["L당 할인", "결제일 %할인"]
    private let nameLabel = UILabel().then {
        $0.text = "카드 별칭"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private lazy var nameTextField = UITextField().then {
        $0.delegate = self
        $0.placeholder = "카드의 이름을 작성해주세요."
        $0.clearButtonMode = .whileEditing
    }
    private let textFieldUnderLineview = UIView().then {
        $0.backgroundColor = .systemGray
    }
    private let saleTypeLabel = UILabel().then {
        $0.text = "혜택 타입"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private lazy var segmentControl = UISegmentedControl(items: items).then {
        $0.selectedSegmentIndex = 0
        $0.selectedSegmentTintColor = Asset.Colors.mainColor.color
    }
    private let salePriceLabel = UILabel().then {
        $0.text = "할인 금액"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private let salePriceValueLabel = UILabel().then {
        $0.text = "0원"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.layer.cornerRadius = 10.0
        $0.layer.masksToBounds = true
        $0.backgroundColor = Asset.Colors.mainColor.color
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 20)
    }
    private let stepper = UIStepper().then {
        $0.stepValue = 1
        $0.minimumValue = 0
        $0.maximumValue = 200
        $0.wraps = true
    }
    private lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        BrandTypeTableViewCell.register($0)
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
        
        let font = FontFamily.NanumSquareRound.regular.font(size: 15)
        
        let normalAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                              .foregroundColor: UIColor.black]
        let selectedAttribute: [NSAttributedString.Key: Any] = [.font: font,
                                                                .foregroundColor: UIColor.white]
        
        segmentControl.setTitleTextAttributes(normalAttribute, for: .normal)
        segmentControl.setTitleTextAttributes(selectedAttribute, for: .selected)
        
        view.addSubview(nameLabel)
        view.addSubview(nameTextField)
        view.addSubview(textFieldUnderLineview)
        view.addSubview(saleTypeLabel)
        view.addSubview(segmentControl)
        view.addSubview(salePriceLabel)
        view.addSubview(salePriceValueLabel)
        view.addSubview(stepper)
        view.addSubview(tableView)
        
        nameLabel.snp.makeConstraints {
            $0.top.left.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        textFieldUnderLineview.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(8)
            $0.left.right.equalTo(nameTextField)
            $0.height.equalTo(1)
        }
        saleTypeLabel.snp.makeConstraints {
            $0.top.equalTo(textFieldUnderLineview.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(16)
        }
        segmentControl.snp.makeConstraints {
            $0.top.equalTo(saleTypeLabel.snp.bottom).offset(12)
            $0.left.right.equalToSuperview().inset(16)
        }
        salePriceLabel.snp.makeConstraints {
            $0.top.equalTo(segmentControl.snp.bottom).offset(24)
            $0.left.equalToSuperview().offset(16)
        }
        stepper.snp.makeConstraints {
            $0.top.equalTo(salePriceLabel.snp.bottom).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        salePriceValueLabel.snp.makeConstraints {
            $0.top.equalTo(salePriceLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalTo(stepper.snp.left)
            $0.height.equalTo(stepper)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(salePriceValueLabel.snp.bottom).offset(12)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        segmentControl.rx.value
            .map { $0 == 0 ? true : false }
            .bind(with: self, onNext: { owner, isSelect in
                owner.stepper.value = 0.0
                owner.stepper.stepValue = isSelect ? 1.0 : 0.1
                owner.stepper.maximumValue = isSelect ? 500.0 : 50.0
                owner.salePriceValueLabel.text = "0\(isSelect ? "원" : "%")"
            })
            .disposed(by: bag)
        
        stepper.rx.value
            .map { self.segmentControl.selectedSegmentIndex == 0 ? "\(Int($0))원" : String(format: "%.1f%%", $0) }
            .bind(to: salePriceValueLabel.rx.text)
            .disposed(by: bag)
        
        viewModel.brandSubject
            .bind(to: tableView.rx.items(cellIdentifier: BrandTypeTableViewCell.id,
                                         cellType: BrandTypeTableViewCell.self)) { index, brand, cell in
                cell.fetchData(brand: brand)
                guard brand != "전체" else {
                    cell.brandSelectedSwitch
                        .rx
                        .isOn
                        .subscribe(onNext: {
                            self.isAllSwitchButton.onNext($0)
                        })
                        .disposed(by: self.rx.disposeBag)
                    
                    return
                }
                
                self.isAllSwitchButton
                    .subscribe(onNext: {
                        guard !self.isLauchSetting else {
                            cell.brandSelectedSwitch.isOn = $0
                            DefaultData.shared.brandsSubject.accept($0 ? self.viewModel.allBrands : [])
                            return
                        }
                        
                        self.isLauchSetting = true
                    })
                    .disposed(by: self.rx.disposeBag)
                
            }
            .disposed(by: rx.disposeBag)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        
        nameTextField.resignFirstResponder()
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

extension AddCardVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.text?.count ?? 0 < 6 else { return false }
        
        return true
    }
}
