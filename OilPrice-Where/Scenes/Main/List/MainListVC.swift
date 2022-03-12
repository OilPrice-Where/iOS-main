//
//  MainListVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import TMapSDK
import NMapsMap
import SCLAlertView

protocol MainListVCDelegate: AnyObject {
    func touchedCell(info: GasStation)
}

//MARK: GasStationListVC
final class MainListVC: CommonViewController {
    //MARK: - Properties
    var viewModel: MainListViewModel!
    weak var delegate: MainListVCDelegate?
    lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .systemGroupedBackground
        $0.dataSource = self
        $0.delegate = self
        GasStationCell.register($0)
    }
    let infoView = InfoListView()
    var noneView = MainListNoneView().then {
        $0.isHidden = true
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Make UI
    func makeUI() {
        navigationItem.title = "주유소 목록"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(infoView)
        view.addSubview(tableView)
        view.addSubview(noneView)
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(30)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        noneView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        // Sorted by Price/Distance
        infoView.priceSortedButton
            .rx
            .tap
            .bind(with: self, onNext: { owner, _ in
                owner.sortButtonTapped(btn: nil)
            })
            .disposed(by: bag)
        infoView.distanceSortedButton
            .rx
            .tap
            .bind(with: self, onNext: { owner, _ in
                owner.sortButtonTapped(btn: nil)
            })
            .disposed(by: bag)
        DefaultData.shared.completedRelay
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configure() {
        noneView.isHidden = !viewModel.stations.isEmpty
        
        infoView.priceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
        infoView.distanceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
    }
    
    @objc
    func sortButtonTapped(btn: UIButton?) {
        guard let text = btn?.titleLabel?.text else { return }
        
        let isPriceSorted = text == "가격순"
        
        infoView.priceSortedButton.isSelected = isPriceSorted
        infoView.distanceSortedButton.isSelected = !isPriceSorted
        
        if isPriceSorted {
            infoView.priceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
            infoView.distanceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        } else {
            infoView.priceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
            infoView.distanceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        }
        
        viewModel.sortedList(isPrice: isPriceSorted)
        
        tableView.reloadData()
    }
}

//MARK: - TableViewDataSources & Delegate
extension MainListVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.stations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GasStationCell.id, for: indexPath) as? GasStationCell else { return UITableViewCell() }
        
        cell.configure(station: viewModel.stations[indexPath.section], indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
}

extension MainListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.touchedCell(info: viewModel.stations[indexPath.section])
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 163.2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 12))
        view.backgroundColor = .systemGroupedBackground
        return view
    }
}

extension MainListVC: GasStationCellDelegate {
    // 즐겨찾기 설정 및 해제
    func touchedFavoriteButton(id: String?, indexPath: IndexPath?) {
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = id, let _indexPath = indexPath, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
            }
            return
        }
        var newFaovorites = faovorites
        isDeleted ? newFaovorites = newFaovorites.filter { $0 != _id } : newFaovorites.append(_id)
        
        DefaultData.shared.favoriteSubject.accept(newFaovorites)
        tableView.reloadRows(at: [_indexPath], with: .none)
    }
    
    func touchedDirectionButton(info: GasStation?) {
        requestDirection(station: info)
    }
}

// HeaderView 설정
//func fetchAverageCosts() {
//    firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
//        self.gasolineCostLabel.text = data["price"] as? String ?? ""
//        self.gasolineTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.gasolineUpDownImageView.image = Asset.Images.priceUpIcon.image
//        }else {
//            self.gasolineUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//    }
//    firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
//        self.dieselCostLabel.text = data["price"] as? String ?? ""
//        self.dieselTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.dieselUpDownImageView.image = Asset.Images.priceUpIcon.image
//        }else {
//            self.dieselUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//
//    }
//    firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
//        self.lpgCostLabel.text = data["price"] as? String ?? ""
//        self.lpgTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.lpgUpDownImageView.image = Asset.Images.priceUpIcon.image
//        } else {
//            self.lpgUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//    }
//}
