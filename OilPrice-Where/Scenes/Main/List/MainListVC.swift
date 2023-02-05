//
//  MainListVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import NMapsMap
import FirebaseAnalytics

protocol MainListVCDelegate: AnyObject {
    func touchedCell(info: GasStation)
}
//MARK: GasStationListVC
final class MainListVC: CommonViewController {
    enum Section {
        case station
    }
    
    //MARK: - Properties
    let infoView = InfoListView()
    var viewModel: MainListViewModel!
    weak var delegate: MainListVCDelegate?
    private var notiObject: NSObjectProtocol?
    var dataSource: UICollectionViewDiffableDataSource<Section, GasStation>?
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.delegate = self
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        GasStationCell.register($0)
    }
    
    private var noneView = MainListNoneView().then {
        $0.isHidden = true
    }
    
    //MARK: - Life Cycle
    deinit {
        if let noti = notiObject { NotificationCenter.default.removeObserver(noti) }
        notiObject = nil
    }
    
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
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "주유소 목록"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(infoView)
        view.addSubview(collectionView)
        view.addSubview(noneView)
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(30)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        noneView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
        
        performDataSource()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        flowLayout.itemSize = CGSize(width: itemWidth, height: 168.0)
        
        flowLayout.invalidateLayout()
    }
    
    //MARK: - Rx Binding..
    private func rxBind() {
        viewModel.stations
            .map { !$0.isEmpty }
            .bind(to: noneView.rx.isHidden)
            .disposed(by: rx.disposeBag)
        viewModel.stations
            .bind(with: self, onNext: { owner, stations in
                owner.performDataSnapshot(stations: stations)
            })
            .disposed(by: rx.disposeBag)
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
                owner.collectionView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Method
    private func configure() {
        notiObject = NotificationCenter.default.addObserver(forName: NSNotification.Name("stationsUpdated"),
                                                            object: nil,
                                                            queue: .main) { [weak self] noti in
            guard let stations = noti.userInfo?["stations"] as? [GasStation] else { return }
            self?.viewModel.stations.onNext(stations)
        }
        
        infoView.priceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
        infoView.distanceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
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
    
    @objc
    private func sortButtonTapped(btn: UIButton?) {
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
    }
}

extension MainListVC {
    func performDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, GasStation>(collectionView: collectionView, cellProvider: { collectionView, indexPath, station in
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GasStationCell.id, for: indexPath) as? GasStationCell else { return UICollectionViewCell() }
            
            cell.configure(station: station, indexPath: indexPath)
            cell.delegate = self
            
            return cell
        })
    }
    
    func performDataSnapshot(stations: [GasStation]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, GasStation>()
        snapshot.appendSections([.station])
        snapshot.appendItems(stations)
        self.dataSource?.apply(snapshot, animatingDifferences: false)
    }
}

extension MainListVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let stations = try? viewModel.stations.value() else { return }
        
        delegate?.touchedCell(info: stations[indexPath.item])
        navigationController?.popViewController(animated: true)
    }
}

extension MainListVC: GasStationCellDelegate {
    // 즐겨찾기 설정 및 해제
    func touchedFavoriteButton(id: String?) {
        let event = "tap_list_favorite"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = id, faovorites.count < 6 else { return }
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
        
        let msg = isDeleted ? "즐겨 찾는 주유소가 삭제되었습니다." : "즐겨 찾는 주유소에 추가되었습니다."
        let lbl = Preferences.showToast(width: 240, message: msg, numberOfLines: 1)
        view.hideToast()
        view.showToast(lbl, position: .top)
    }
    
    func touchedDirectionButton(info: GasStation?) {
        let event = "tap_list_navigation"
        let parameters = [
            "file": #file,
            "function": #function,
            "eventDate": DefaultData.shared.currentTime
        ]
        
        Analytics.setUserProperty("ko", forName: "country")
        Analytics.logEvent(event, parameters: parameters)
        
        requestDirection(station: info)
    }
}
