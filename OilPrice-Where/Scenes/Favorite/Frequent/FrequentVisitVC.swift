//
//  FrequentVisitVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import Toast
import SnapKit


//MARK: 자주 방문한 List
final class FrequentVisitVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: FrequentVisitViewModel
    
    private var dataSoruce: FrequentVisitDataSource!
    private var collectionView: UICollectionView!
    
    private let didSelectItemPublisher = PassthroughSubject<VisitedGasStation, Never>()
    private let didTapFavoritePublisher = PassthroughSubject<VisitedGasStation, Never>()
    private let didTapDirectionPublisher = PassthroughSubject<VisitedGasStation, Never>()
    
    private let emptyLabel = UILabel().then {
        $0.text = UIConstants.EmptyLabel.text
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.font = UIConstants.EmptyLabel.font
    }
    
    
    //MARK: - Life Cycle
    init(viewModel: FrequentVisitViewModel) {
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
}


//MARK: - Binding..
private extension FrequentVisitVC {
    func bindActions() {
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            didSelectItem: didSelectItemPublisher.eraseToAnyPublisher(),
            didTapDirectionStation: didTapDirectionPublisher.eraseToAnyPublisher(),
            didTapFavoriteStation: didTapFavoritePublisher.eraseToAnyPublisher()
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: FrequentVisitViewModel.Output) {
        output.visitedStations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visitedStations in
                self?.emptyLabel.isHidden = visitedStations.isNotEmpty
                self?.dataSoruce.applySnapshot(with: visitedStations)
            }
            .store(in: &cancellable)
        
        output.showStationDetail
            .receive(on: DispatchQueue.main)
            .sink { [weak self] detailVC in
                self?.navigationController?.pushViewController(detailVC, animated: true)
            }
            .store(in: &cancellable)
        
        output.openNavigation
            .receive(on: DispatchQueue.main)
            .sink { destinationURL in
                UIApplication.shared.open(destinationURL)
            }
            .store(in: &cancellable)
        
        output.showToast
            .receive(on: DispatchQueue.main)
            .sink { [weak self] message in
                self?.view.hideToast()
                
                let toast = Preferences.showToast(width: 240, message: message, numberOfLines: 1)
                self?.view.showToast(toast, position: .top)
            }
            .store(in: &cancellable)
    }
}


//MARK: - CollectionView
extension FrequentVisitVC: UICollectionViewDelegate {
    private final class FrequentVisitDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, VisitedGasStation> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, VisitedGasStation>
        
        func applySnapshot(with stations: [VisitedGasStation],
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
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = .clear
        }
        
        view.addSubview(collectionView)
        configureDataSource()
    }
    
    private func configureDataSource() {
        let cellRegistration = FrequentVisitCell.cellRegistration(self, settingUseCase: viewModel.settingUseCase)
        self.dataSoruce = FrequentVisitDataSource(collectionView: collectionView) { collectionView, indexPath, visitStation in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: visitStation
            )
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: 139.2)
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let visitStation = dataSoruce.itemIdentifier(for: indexPath) else {
            return
        }
        
        didSelectItemPublisher.send(visitStation)
    }
}


//MARK: - FrequentVisitCellDelegate
extension FrequentVisitVC: FrequentVisitCellDelegate {    
    func didTapFavoriteButton(station: VisitedGasStation) {
        didTapFavoritePublisher.send(station)
    }
    
    func didTapDirectionButton(station: VisitedGasStation) {
        didTapDirectionPublisher.send(station)
    }
}


//MARK: - Set UI
private extension FrequentVisitVC {
    enum UIConstants {
        enum EmptyLabel {
            static let text: String = "방문하신 주유소가 없습니다."
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 18)
        }
    }
    
    func makeUI() {
        configureCollectionView()
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(emptyLabel)
    }
    
    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
