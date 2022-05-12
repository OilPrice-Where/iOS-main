//
//  HistoriesVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

//MARK: HistoriesVC
final class HistoriesVC: CommonViewController {
    //MARK: - Properties
    private lazy var tableView = UITableView().then {
        $0.delegate = self
        $0.dataSource = self
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .white
        HistoryTableViewCell.register($0)
    }
    private lazy var emptyLabel = UILabel().then {
        $0.text = "방문하신 주유소가 없습니다."
        $0.textAlignment = .center
        $0.isHidden = !DataManager.shared.stationList.isEmpty
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 20)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        navigationItem.title = "방문 내역"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = .white
        view.addSubview(tableView)
        view.addSubview(emptyLabel)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        emptyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        DataManager.shared.stationListIsNotEmpty
            .bind(to: emptyLabel.rx.isHidden)
            .disposed(by: bag)
    }
}

//MARK: UITableView DataSource & Delegate
extension HistoriesVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DataManager.shared.stationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withType: HistoryTableViewCell.self, for: indexPath)
        
        cell.configure(station: DataManager.shared.stationList[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let target = DataManager.shared.stationList[indexPath.row]
            DataManager.shared.delete(station: target)
            DataManager.shared.stationList.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 127
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "길 안내", message: "해당 주유소를 재방문 하시겠습니까?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .default) { [weak self] _ in
            let target = DataManager.shared.stationList[indexPath.row]
            let station = GasStation(name: target.name, brand: target.brand, x: target.katecX, y: target.katecY)
            self?.requestDirection(station: station)
            
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
