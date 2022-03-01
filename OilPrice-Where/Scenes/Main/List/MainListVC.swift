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

//MARK: GasStationListVC
final class MainListVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    var viewModel: MainListViewModel!
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
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.bottom.right.equalToSuperview()
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
    }
    
    func configure() {
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
        
        cell.configure(station: viewModel.stations[indexPath.section])
        
        return cell
    }
}

extension MainListVC: UITableViewDelegate {
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
