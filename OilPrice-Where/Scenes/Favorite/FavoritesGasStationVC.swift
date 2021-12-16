//
//  FavoritesGasStationVC.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Foundation
import TMapSDK
import RxSwift
import RxCocoa
import NSObject_Rx
import CoreLocation

final class FavoritesGasStationVC: CommonViewController {
    //MARK: - Properties
    var notiObject: NSObjectProtocol?
    var reachability: Reachability? = Reachability() //Network
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
        reachability?.stopNotifier()
        reachability = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        setNetworkSetting()
        bindViewModel()
        
        notiObject = NotificationCenter.default.addObserver(forName: NSNotification.Name("navigationClickEvent"),
                                                            object: nil,
                                                            queue: .main) { self.naviClickEvenet(noti: $0) }
    }
    
    //MARK: - Configure UI
    func configureUI() {
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
                let viewModel = FavoriteCellViewModel(id: id)
                cell.viewModel = viewModel
                cell.bindViewModel()
            }
            .disposed(by: rx.disposeBag)
        
        collectionView
            .rx
            .setDelegate(self)
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Functions..
    func setNetworkSetting() {
        do {
            try reachability?.startNotifier()
        } catch {
            print(error.localizedDescription)
        }
        
        reachability?.whenReachable = { _ in
            if let favArr = try? DefaultData.shared.favoriteSubject.value() {
                self.noneFavoriteView.isHidden = favArr.isEmpty
                DefaultData.shared.favoriteSubject.onNext(favArr)
            }
        }
        
        reachability?.whenUnreachable = { _ in
            self.noneFavoriteView.isHidden = false
        }
    }
    
    func naviClickEvenet(noti: Notification) {
        guard let userInfo = noti.userInfo,
              let katecX = userInfo["katecX"] as? Double,
              let katecY = userInfo["katecY"] as? Double,
              let stationName = userInfo["stationName"] as? String,
              let navi = userInfo["naviType"] as? String,
              let type = NaviType(rawValue: navi) else { return }
        let coordinator = Converter.convertKatecToWGS(katec: KatecPoint(x: katecX, y: katecY))
        
        switch type {
        case .tMap:
            if TMapApi.isTmapApplicationInstalled() {
                let _ = TMapApi.invokeRoute(stationName, coordinate: coordinator)
                
                return
            }
            
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인",
                                         style: .default) { _ in
                guard let url = URL(string: TMapApi.getTMapDownUrl()),
                      UIApplication.shared.canOpenURL(url) else { return }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        case .kakao:
            let destination = KNVLocation(name: stationName,
                                          x: NSNumber(value: katecX),
                                          y: NSNumber(value: katecY))
            let options = KNVOptions()
            options.routeInfo = false
            let params = KNVParams(destination: destination,
                                   options: options)
            KNVNaviLauncher.shared().navigate(with: params) { (error) in
                self.handleError(error: error)
            }
        }
    }
    
    // 길안내 에러 발생
    func handleError(error: Error?) {
        guard let error = error as NSError? else { return }
        
        let alert = UIAlertController(title: title,
                                      message: error.localizedFailureReason,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
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
