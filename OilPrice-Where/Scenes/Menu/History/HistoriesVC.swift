//
//  HistoriesVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/12.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


//MARK: HistoriesVC
final class HistoriesVC: CommonViewController {
    
    //MARK: - Properties
    private let viewModel: HistoriesViewModel
    
    private var collectionView: UICollectionView!
    private var dataSource: HistoriesDataSource!
    
    private let swipeToDeletePublisher = PassthroughSubject<VisitedGasStation, Never>()
    private let didSelectItemPublisher = PassthroughSubject<VisitedGasStation, Never>()
    private let alertConfirmationPublisher = PassthroughSubject<VisitedGasStation, Never>()
    
    private let emptyLabel = UILabel().then {
        $0.text = "방문하신 주유소가 없습니다."
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.isHidden = true
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
    }
    
    //MARK: - Life Cycle
    init(viewModel: HistoriesViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        bindUI()
        bindActions()
    }
}

//MARK: - Action
private extension HistoriesVC {
    func bindUI() {
        viewModel.visitedStations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visitedStation in
                self?.emptyLabel.isHidden = !visitedStation.isEmpty
                self?.dataSource.applySnapshot(with: visitedStation)
            }
            .store(in: &cancellable)
    }
    
    func bindActions() {
        let output = viewModel.trasform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            swipeToDelete: swipeToDeletePublisher.eraseToAnyPublisher(),
            didSelectItem: didSelectItemPublisher.eraseToAnyPublisher(),
            alertConfirmationPublisher: alertConfirmationPublisher.eraseToAnyPublisher()
        ))
        
        // Present alert
        output.presentNavigationAlert
            .receive(on: DispatchQueue.main)
            .sink { [weak self] visitedStation in
                self?.presentNavigationAlert(visitedStation: visitedStation)
            }
            .store(in: &cancellable)
        
        // Move Navigation
        output.moveNavigation
            .receive(on: DispatchQueue.main)
            .sink { targetURL in
                guard UIApplication.shared.canOpenURL(targetURL) else {
                    return
                }
                UIApplication.shared.open(targetURL, options: [:], completionHandler: nil)
            }
            .store(in: &cancellable)
    }
    
    /// Present Alert
    private func presentNavigationAlert(visitedStation station: VisitedGasStation) {
        let alert = UIAlertController(
            title: "길 안내",
            message: "해당 주유소를 재방문 하시겠습니까?",
            preferredStyle: .alert
        )
        
        let okAction = UIAlertAction(
            title: "확인",
            style: .default
        ) { [weak self] _ in
            self?.alertConfirmationPublisher.send((station))
        }
        
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    /// 스와이프 액션 생성
    func makeSwipeActions(for indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // 삭제 액션 생성
        let deleteAction = UIContextualAction(style: .destructive, title: "삭제") { [weak self] action, view, completion in
            self?.handleDeleteAction(at: indexPath)
            completion(true)
        }
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        // 액션을 수행할 때 전체 셀 스와이프를 막지 않으려면 false로 설정
        configuration.performsFirstActionWithFullSwipe = true
        return configuration
    }
    
    /// 스냅샷을 업데이트하여 아이템 삭제
    func handleDeleteAction(at indexPath: IndexPath) {
        guard var currentSnapshot = dataSource?.snapshot(),
              let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        currentSnapshot.deleteItems([item])
        dataSource.apply(currentSnapshot, animatingDifferences: true)
        
        swipeToDeletePublisher.send(item)
    }
}

//MARK: - Set UI
private extension HistoriesVC {
    final class HistoriesDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, VisitedGasStation> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, VisitedGasStation>
        
        func applySnapshot(with stations: [VisitedGasStation],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendItems(stations, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    func makeUI() {
        view.backgroundColor = Asset.Colors.tableViewBackground.color
        
        configureNavigation()
        configureEmptyLabel()
        configureCollectionView()
        configureDataSource()
    }
    
    func configureNavigation() {
        navigationItem.title = "방문 내역"
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [
            .font: FontFamily.NanumSquareRound.bold.font(size: 17),
            .foregroundColor: UIColor.white
        ]
    }
    
    func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        configuration.trailingSwipeActionsConfigurationProvider = { [weak self] indexPath in
            return self?.makeSwipeActions(for: indexPath)
        }
        
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = Asset.Colors.tableViewBackground.color
        }
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    func configureDataSource() {
        self.dataSource = HistoriesDataSource(collectionView: collectionView) { collectionView, indexPath, aboutMe in
            collectionView.dequeueConfiguredReusableCell(using: HistoryCell.cellRegistration, for: indexPath, item: aboutMe)
        }
    }
    
    func configureEmptyLabel() {
        view.addSubview(emptyLabel)
        emptyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension HistoriesVC: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let station = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        didSelectItemPublisher.send(station)
    }
}
