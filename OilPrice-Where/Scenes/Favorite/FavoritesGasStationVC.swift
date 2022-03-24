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
//MARK: 즐겨찾는 주유소 VC
final class FavoritesGasStationVC: CommonViewController {
    //MARK: - Properties
    private let width = UIScreen.main.bounds.width - 75.0
    private let height = 411
    private var fromTap = false
    private var notiObject: NSObjectProtocol?
    private let noneFavoriteView = NoneFavoriteView()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.backgroundColor = .clear
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.alwaysBounceHorizontal = false
        $0.allowsMultipleSelection = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        FavoriteCollectionViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    deinit {
        if let noti = notiObject { NotificationCenter.default.removeObserver(noti) }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Set UI
    func makeUI() {
        navigationItem.title = "자주 가는 주유소"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(collectionView)
        view.addSubview(noneFavoriteView)
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            $0.left.right.equalToSuperview()
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
    private func fetchLayout() -> UICollectionViewFlowLayout {
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
