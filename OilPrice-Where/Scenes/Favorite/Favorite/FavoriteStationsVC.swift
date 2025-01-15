//
//  FavoriteStationsVC.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


//MARK: 즐겨찾는 주유소 VC
final class FavoriteStationsVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: FavoriteStationsViewModel
    
    private var dataSoruce: FavoriteStationsDataSource!
    private var collectionView: UICollectionView!
    
    private let noneFavoriteView = NoneFavoriteView()
    
    
    //MARK: - Life Cycle
    init(viewModel: FavoriteStationsViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindActions()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = UIConstants.CollectionView.itemSize
            flowLayout.invalidateLayout()
        }
    }
}


//MARK: - Binding..
private extension FavoriteStationsVC {
    func bindActions() {
        DefaultData.shared.favoriteSubject
            .map { !$0.isEmpty }
            .assign(to: \.isHidden, on: noneFavoriteView)
            .store(in: &cancellable)
        
        //                guard let vc = UIApplication.shared.customKeyWindow?.visibleViewController as? UIViewController else { return }
        //                let lbl = Preferences.showToast(width: 240, message: "즐겨 찾는 주유소가 삭제되었습니다.", numberOfLines: 1)
        //
        //                vc.view.hideToast()
        //                vc.view.showToast(lbl, position: .bottom)
        
        DefaultData.shared.favoriteSubject
            .bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: FavoriteCollectionViewCell.id,
                                                             cellType: FavoriteCollectionViewCell.self,
                                                             cellConfig: { cell, indexPath, id in
                cell.viewModel.requestStationsInfo(id: id)
                cell.layer.cornerRadius = 35
                cell.delegate = self
                cell.id = id
            }))
            .store(in: &cancellable)
        
        viewModel.isLoadingSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isLoad in
                guard let owner = self else { return }
                isLoad ? owner.loadingView.activityIndicator.startAnimating() : owner.loadingView.activityIndicator.stopAnimating()
                owner.loadingView.isHidden = isLoad
            }
            .store(in: &viewModel.cancellable)
        
        viewModel.infoSubject.combineLatest(DefaultData.shared.oilSubject)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] station, title in
                guard let owner = self else { return }
                owner.oilPriceLabel.text = owner.viewModel.displayPriceInfomation(priceList: station?.prices)
            }
            .store(in: &viewModel.cancellable)
    }
}


//MARK: - CollectionView
extension FavoriteStationsVC: UICollectionViewDelegate {
    private final class FavoriteStationsDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, GasStationDetail> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, GasStationDetail>
        
        func applySnapshot(with stations: [GasStationDetail],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendItems(stations, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    private func configureCollectionView() {
        let layout = collectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.decelerationRate = UIScrollViewDecelerationRateFast
            $0.alwaysBounceHorizontal = false
            $0.allowsMultipleSelection = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        view.addSubview(collectionView)
        configureDataSource()
    }
    
    private func configureDataSource() {
        self.dataSoruce = FavoriteStationsDataSource(collectionView: collectionView) { [weak self] collectionView, indexPath, visitStation in
            guard let self else { return .init() }
            let cellRegistration = FavoriteCell.cellRegistration(self, fuelType: <#T##FuelType#>)
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: visitStation
            )
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = UIConstants.CollectionView.lineSpacing
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.scrollDirection = .horizontal
        flowLayout.itemSize = UIConstants.CollectionView.itemSize
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 37.5, bottom: 0, right: 37.5)
        return flowLayout
    }
    
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


//MARK: - FavoriteCellDelegate
extension FavoriteStationsVC: FavoriteCellDelegate {
    func didTapFavorite(station: GasStationDetail) {
        <#code#>
    }
    
    func didTapAddressLabel(station: GasStationDetail) {
        let lbl = Preferences.showToast(message: "주유소 주소가 복사되었습니다.")
        view.hideToast()
        view.showToast(lbl)
    }
    
    func didTapPhoneNumberLabel(station: GasStationDetail) {
        <#code#>
    }
    
    func didTapDirectionButton(station: GasStationDetail) {
        requestDirection(station: station)
    }
}


//MARK: - Set UI
private extension FavoriteStationsVC {
    enum UIConstants {
        enum CollectionView {
            static let centerYOffset: CGFloat = -44
            static let height: CGFloat = 411
            
            static let lineSpacing: CGFloat = 25
            static let itemSize: CGSize = {
                let screenWidth = UIScreen.main.bounds.width - 75
                let current = UIDevice.current
                let itemWidth = current.userInterfaceIdiom == .phone ? screenWidth : current.orientation == .portrait ? screenWidth / 2 - 12.5 : screenWidth / 3 - (50 / 3)
                return .init(width: itemWidth, height: height)
            }()
        }
    }
    
    func makeUI() {
        configureCollectionView()
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(noneFavoriteView)
    }
    
    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.CollectionView.centerYOffset)
            $0.height.equalTo(UIConstants.CollectionView.height)
        }
        noneFavoriteView.snp.makeConstraints {
            $0.edges.equalTo(collectionView)
        }
    }
}
