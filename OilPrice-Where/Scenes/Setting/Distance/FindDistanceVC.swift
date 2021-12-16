//
//  FindDistanceVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx

class FindDistanceVC: CommonViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: FindDistanceViewModel!
    
    lazy var tableView = UITableView().then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        FindDistanceTableViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
    }
    
    //MARK: - View Binding..
    func bindViewModel() {
        viewModel.distanceSubject
            .bind(to: tableView.rx.items(cellIdentifier: FindDistanceTableViewCell.id,
                                         cellType: FindDistanceTableViewCell.self)) { index, distance, cell in
                cell.fetch(distance: distance)
                
                let displayDistance = Preferences.distanceKM(KM: distance)
                guard let currentDistance = try? DefaultData.shared.radiusSubject.value(),
                    displayDistance == currentDistance else { return }
                
                self.tableView.selectRow(at: IndexPath(row: index, section: 0),
                                         animated: false,
                                         scrollPosition: .none)
            }
            .disposed(by: rx.disposeBag)
        
        tableView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Configure UI
    func configureUI() {
        navigationItem.title = "검색 반경"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

//MARK: - UITableView Delegate
extension FindDistanceVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let distances = viewModel.distanceSubject.value
        let radius = Preferences.distanceKM(KM: distances[indexPath.row])
        
        DefaultData.shared.radiusSubject.onNext(radius)
    }
}
