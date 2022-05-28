//
//  FrequentVisitVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

//MARK: 자주 방문한 List
final class FrequentVisitVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    let viewModel = FrequentVisitViewModel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        GasStationCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        viewModel.output.stations
            .bind(to: collectionView.rx.items(cellIdentifier: GasStationCell.id,
                                              cellType: GasStationCell.self)) { item, station, cell in
                print(station.name, station.count)
            }
            .disposed(by: bag)
    }
    
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: 163.2)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return flowLayout
    }
}
