//
//  FavoritesGasStationVC.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Foundation
import NMapsMap
import Combine
import CombineCocoa
import CombineDataSources
import CoreLocation
import FirebaseAnalytics
//MARK: 즐겨찾는 주유소 VC
final class FavoritesGasStationVC: CommonViewController {
    //MARK: - Properties
    private var fromTap = false
    private let noneFavoriteView = NoneFavoriteView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.delegate = self
        $0.backgroundColor = .clear
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.alwaysBounceHorizontal = false
        $0.allowsMultipleSelection = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        FavoriteCollectionViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindViewModel()
    }
    
    //MARK: - Set UI
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let itemWidth: CGFloat = fetchItemWidth()
        let itemSize = CGSize(width: itemWidth, height: 411.0)
        flowLayout.itemSize = itemSize
        
        flowLayout.invalidateLayout()
    }
    
    func makeUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(collectionView)
        view.addSubview(noneFavoriteView)
        
        collectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(-44)
            $0.height.equalTo(411)
        }
        noneFavoriteView.snp.makeConstraints {
            $0.edges.equalTo(collectionView)
        }
    }
    
    //MARK: - Rx Binding..
    func bindViewModel() {
        DefaultData.shared.favoriteSubject
            .map { !$0.isEmpty }
            .assign(to: \.isHidden, on: noneFavoriteView)
            .store(in: &cancelBag)
        
        DefaultData.shared.favoriteSubject
            .bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: FavoriteCollectionViewCell.id,
                                                             cellType: FavoriteCollectionViewCell.self,
                                                             cellConfig: { cell, indexPath, id in
                cell.viewModel.requestStationsInfo(id: id)
                cell.layer.cornerRadius = 35
                cell.delegate = self
                cell.id = id
            }))
            .store(in: &cancelBag)
    }
    
    //MARK: - Functions..
    override func setNetworkSetting() {
        super.setNetworkSetting()
        
        reachability?.whenReachable = { [weak self] _ in
            let favArr = DefaultData.shared.favoriteSubject.value
            self?.noneFavoriteView.isHidden = favArr.isEmpty
            DefaultData.shared.favoriteSubject.send(favArr)
            self?.collectionView.isHidden = false
            self?.collectionView.reloadData()
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            self?.notConnect()
            self?.collectionView.isHidden = true
            self?.noneFavoriteView.isHidden = false
        }
    }
    
    // set collectionView flow layout
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let itemSize = CGSize(width: fetchItemWidth(), height: 411.0)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 25
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = itemSize
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 37.5, bottom: 0, right: 37.5)
        return flowLayout
    }
    
    private func fetchItemWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 75
        let current = UIDevice.current
        return current.userInterfaceIdiom == .phone ? screenWidth : current.orientation == .portrait ? screenWidth / 2 - 12.5 : screenWidth / 3 - (50 / 3)
    }
}

//MARK: - UICollectionView Delegate
extension FavoritesGasStationVC: UICollectionViewDelegate {
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        guard let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        let cellSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellSpacing
        let roundedIndex = round(index)
        offset = CGPoint(x: roundedIndex * cellSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        targetContentOffset.pointee = offset
    }
}

extension FavoritesGasStationVC: FavoriteCollectionViewCellDelegate {
    func touchedAddressLabel() {
        let lbl = Preferences.showToast(message: "주유소 주소가 복사되었습니다.")
        view.hideToast()
        view.showToast(lbl)
    }
    
    func touchedDirection(station: GasStation?) {
        requestDirection(station: station)
    }
}
