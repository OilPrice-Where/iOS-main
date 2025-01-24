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
import Toast
import SnapKit


//MARK: 즐겨찾는 주유소 VC
final class FavoriteStationsVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: FavoriteStationsViewModel
    
    private var dataSoruce: FavoriteStationsDataSource!
    private var collectionView: UICollectionView!
    
    private let didTapAddressPublisher = PassthroughSubject<GasStationDetail, Never>()
    private let didTapFavoritePublisher = PassthroughSubject<GasStationDetail, Never>()
    private let didTapDirectionPublisher = PassthroughSubject<GasStationDetail, Never>()
    private let didTapPhoneNumberPublisher = PassthroughSubject<GasStationDetail, Never>()
    
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
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            didTapAddressStation: didTapAddressPublisher.eraseToAnyPublisher(),
            didTapPhoneNumberStation: didTapPhoneNumberPublisher.eraseToAnyPublisher(),
            didTapDirectionStation: didTapDirectionPublisher.eraseToAnyPublisher(),
            didTapDeleteFavoriteStation: didTapFavoritePublisher.eraseToAnyPublisher()
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: FavoriteStationsViewModel.Output) {
        output.favoriteStations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favoriteStations in
                self?.noneFavoriteView.isHidden = favoriteStations.isNotEmpty
                self?.dataSoruce.applySnapshot(with: favoriteStations)
            }
            .store(in: &cancellable)
        
        output.openURL
            .receive(on: DispatchQueue.main)
            .sink { destinationURL in
                guard UIApplication.shared.canOpenURL(destinationURL) else {
                    return
                }
                UIApplication.shared.open(destinationURL)
            }
            .store(in: &cancellable)
        
        output.showToast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.view.hideToast()
                
                let toast = Preferences.showToast(width: 240, message: message, numberOfLines: 1)
                self?.view.showToast(toast)
            }
            .store(in: &cancellable)
    }
}


//MARK: - CollectionView
extension FavoriteStationsVC: UICollectionViewDelegate {
    private final class FavoriteStationsDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, GasStationDetail> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, GasStationDetail>
        
        func applySnapshot(with stations: [GasStationDetail],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendSections([.main])
            snapshot.appendItems(stations, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    private func configureCollectionView() {
        let layout = collectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.backgroundColor = .clear
            $0.decelerationRate = UIScrollView.DecelerationRate.fast
            $0.alwaysBounceHorizontal = false
            $0.allowsMultipleSelection = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        view.addSubview(collectionView)
        configureDataSource()
    }
    
    private func configureDataSource() {
        let cellRegistration = FavoriteCell.cellRegistration(self, fuelType: viewModel.fuelType)
        self.dataSoruce = FavoriteStationsDataSource(collectionView: collectionView) { collectionView, indexPath, visitStation in
            collectionView.dequeueConfiguredReusableCell(
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
        didTapFavoritePublisher.send(station)
    }
    
    func didTapAddressLabel(station: GasStationDetail) {
        didTapAddressPublisher.send(station)
    }
    
    func didTapPhoneNumberLabel(station: GasStationDetail) {
        didTapPhoneNumberPublisher.send(station)
    }
    
    func didTapDirectionButton(station: GasStationDetail) {
        didTapDirectionPublisher.send(station)
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
