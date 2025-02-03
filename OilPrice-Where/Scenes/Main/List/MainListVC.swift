//
//  MainListVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import Toast
import SnapKit


protocol MainListVCDelegate: AnyObject {
    func touchedCell(info: GasStationSummary)
}


//MARK: GasStationListVC
final class MainListVC: CommonViewController {
    //MARK: - Properties
    weak var delegate: MainListVCDelegate?
    
    private let viewModel: MainListViewModel
    
    private let didTapFavoritePublisher = PassthroughSubject<String, Never>()
    private let didTapDirectionPublisher = PassthroughSubject<GasStationSummary, Never>()
    
    private var dataSource: StationListDataSource!
    private var collectionView: UICollectionView!
    
    private let infoView = InfoListView()
    private var noneView = MainListNoneView().then {
        $0.isHidden = true
    }
    
    
    //MARK: - Life Cycle
    init(viewModel: MainListViewModel) {
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUI()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.itemSize = UIConstants.CollectionView.itemSize
            flowLayout.invalidateLayout()
        }
    }
}


//MARK: - Binding..
private extension MainListVC {
    func bindActions() {
        let didTapSortButton = Publishers.Merge(
            infoView.priceSortedButton.tapPublisher.map { true }.eraseToAnyPublisher(),
            infoView.distanceSortedButton.tapPublisher.map { false }.eraseToAnyPublisher()
        ).map { [weak self] isPriceSort in
            self?.infoView.updateSortButton(isPriceSort: isPriceSort)
            return isPriceSort
        }.eraseToAnyPublisher()
        
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            didTapSortButton: didTapSortButton,
            didTapFavoriteStation: didTapFavoritePublisher.eraseToAnyPublisher(),
            didTapDirectionStation: didTapDirectionPublisher.eraseToAnyPublisher()
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: MainListViewModel.Output) {
        output.updateStations
            .receive(on: DispatchQueue.main)
            .sink { [weak self] stations in
                guard let self else { return }
                noneView.isHidden = stations.isNotEmpty
                dataSource.applySnapshot(with: stations)
            }
            .store(in: &cancellable)
        
        output.updateAddress
            .receive(on: DispatchQueue.main)
            .sink { [weak self] fullAddress in
                guard let self else { return }
                infoView.configure(address: fullAddress)
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
extension MainListVC: UICollectionViewDelegate {
    private final class StationListDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, GasStationSummary> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, GasStationSummary>
        
        func applySnapshot(with stations: [GasStationSummary],
                           animatingDifferences: Bool = false) {
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
            $0.backgroundColor = .systemGroupedBackground
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = GasStationCell.cellRegistration(self, settingUseCase: viewModel.settingUseCase)
        self.dataSource = StationListDataSource(collectionView: collectionView) { collectionView, indexPath, station in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: station)
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = UIConstants.CollectionView.lineSpacing
        flowLayout.minimumInteritemSpacing = UIConstants.CollectionView.itemSpacing
        flowLayout.itemSize = UIConstants.CollectionView.itemSize
        flowLayout.sectionInset = UIConstants.CollectionView.sectionInset
        return flowLayout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let station = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.touchedCell(info: station)
        navigationController?.popViewController(animated: true)
    }
}


//MARK: - GasStationCellDelegate
extension MainListVC: GasStationCellDelegate {
    func touchedFavoriteButton(stationID: String) {
        didTapFavoritePublisher.send(stationID)
    }
    
    func touchedDirectionButton(station summary: GasStationSummary) {
        didTapDirectionPublisher.send(summary)
    }
}


//MARK: - Set UI
private extension MainListVC {
    enum UIConstants {
        enum Navigation {
            static let title: String = "주유소 목록"
            static let titleTextAttributes: [NSAttributedString.Key : Any] = [
                .font: FontFamily.NanumSquareRound.bold.font(size: 17),
                .foregroundColor: UIColor.white
            ]
        }
        
        enum InfoView {
            static let height: CGFloat = 30
        }
        
        enum CollectionView {
            private static let width: CGFloat = UIScreen.screenWidth - 32
            
            static let horizontalPadding: CGFloat = 32
            
            static let lineSpacing: CGFloat = 12.0
            static let itemSpacing: CGFloat = 12.0
            
            static let sectionInset: UIEdgeInsets = .init(top: .zero, left: 16, bottom: .zero, right: 16)
            static let itemSize: CGSize = .init(
                width: UIDevice.current.userInterfaceIdiom == .phone ? width : width / 2 - 6,
                height: 163.2
            )
        }
    }
    
    func makeUI() {
        configureCollectionView()
        configureDataSource()
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        navigationItem.title = UIConstants.Navigation.title
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = UIConstants.Navigation.titleTextAttributes
        
        view.backgroundColor = Asset.Colors.mainColor.color
        
        view.addSubview(infoView)
        view.addSubview(collectionView)
        view.addSubview(noneView)
    }
    
    func updateUI() {
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    func setConstraints() {
        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIConstants.InfoView.height)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        noneView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
}
