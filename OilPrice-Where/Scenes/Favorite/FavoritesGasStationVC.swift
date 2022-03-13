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
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation

final class FavoritesGasStationVC: CommonViewController {
    //MARK: - Properties
    var notiObject: NSObjectProtocol?
    let width = UIScreen.main.bounds.width - 75.0
    let height = 411
    var fromTap = false
    
    let titleLabel = UILabel().then {
        $0.text = "자주 가는 주유소"
        $0.textColor = .white
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
    }
    
    lazy var collectionView: UICollectionView = {
        let layout = setupFlowLayout()
        let v = UICollectionView(frame: .zero, collectionViewLayout: layout)
        v.backgroundColor = .clear
        v.decelerationRate = UIScrollViewDecelerationRateFast
        v.alwaysBounceHorizontal = false
        v.allowsMultipleSelection = false
        v.showsVerticalScrollIndicator = false
        v.showsHorizontalScrollIndicator = false
        FavoriteCollectionViewCell.register(v)
        return v
    }()
    
    let noneFavoriteView = NoneFavoriteView()
    
    // Status Bar Color
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    //MARK: - Life Cycle
    deinit {
        notiObject = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindViewModel()
        
        notiObject = NotificationCenter.default.addObserver(forName: NSNotification.Name("navigationClickEvent"),
                                                            object: nil,
                                                            queue: .main) { self.naviClickEvenet(noti: $0) }
    }
    
    //MARK: - Configure UI
    func makeUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(titleLabel)
        view.addSubview(collectionView)
        view.addSubview(noneFavoriteView)
        
        collectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-44)
            $0.height.equalTo(411)
        }
        
        noneFavoriteView.snp.makeConstraints {
            $0.edges.equalTo(collectionView)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.bottom.equalTo(collectionView.snp.top).offset(-15)
        }
    }
    
    //MARK: - View Binding..
    func bindViewModel() {
        DefaultData.shared.favoriteSubject
            .map { !$0.isEmpty }
            .bind(to: noneFavoriteView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        
        DefaultData.shared.favoriteSubject
            .bind(to: collectionView.rx.items(cellIdentifier: FavoriteCollectionViewCell.id,
                                              cellType: FavoriteCollectionViewCell.self)) { index, id, cell in
                cell.layer.cornerRadius = 35
                cell.id = id
                cell.viewModel.requestStationsInfo(id: id)
            }
            .disposed(by: rx.disposeBag)
        
        collectionView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Functions..
    override func setNetworkSetting() {
        super.setNetworkSetting()
        
        reachability?.whenReachable = { [weak self] _ in
            let favArr = DefaultData.shared.favoriteSubject.value
            self?.noneFavoriteView.isHidden = favArr.isEmpty
            DefaultData.shared.favoriteSubject.accept(favArr)
            self?.collectionView.isHidden = false
            self?.collectionView.reloadData()
        }
        
        reachability?.whenUnreachable = { [weak self] _ in
            self?.notConnect()
            self?.collectionView.isHidden = true
            self?.noneFavoriteView.isHidden = false
        }
    }
    
    func naviClickEvenet(noti: Notification) {
        let info = noti.userInfo?["station"] as? GasStation
        requestDirection(station: info)
    }
    
    // set collectionView flow layout
    private func setupFlowLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 25
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = CGSize(width: width, height: CGFloat(height))
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 37.5, bottom: 0, right: 37.5)
        return flowLayout
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
