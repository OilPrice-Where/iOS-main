//
//  FindBrandVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine
import SnapKit


//MARK: 탐색 브랜드 VC
final class FindBrandVC: CommonViewController {
    //MARK: - Properties
    let viewModel: FindBrandViewModel
    
    private var collectionView: UICollectionView!
    private var dataSource: FindBrandDataSource!
    
    private let didToggleSearchBrand = PassthroughSubject<FindBrandViewModel.Brand, Never>()
    
    //MARK: - Life Cycle
    init(viewModel: FindBrandViewModel) {
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


//MARK: - Binding ..
private extension FindBrandVC {
    func bindUI() {
        viewModel.brandSubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] brands in
                self?.dataSource.applySnapshot(with: brands)
            }
            .store(in: &cancellable)
    }
    
    func bindActions() {
        viewModel.bind(action: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            selectedBrand: didToggleSearchBrand.eraseToAnyPublisher()
        ))
    }
}


//MARK: - CollectionView
private extension FindBrandVC {
    final class FindBrandDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, FindBrandViewModel.Brand> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, FindBrandViewModel.Brand>
        
        func applySnapshot(with items: [FindBrandViewModel.Brand],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendSections([.main])
            snapshot.appendItems(items, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    func configureCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
            $0.backgroundColor = Asset.Colors.tableViewBackground.color
        }
        
        view.addSubview(collectionView)
        configureDataSource()
    }
    
    func configureDataSource() {
        let cellRegistration = FindBrandCell.cellRegistration(self)
        self.dataSource = FindBrandDataSource(collectionView: collectionView) { collectionView, indexPath, brand in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: brand
            )
        }
    }
}


//MARK: - FindBrandCellDelegate
extension FindBrandVC: FindBrandCellDelegate {
    func findBrandCell(_ cell: FindBrandCell, didToggleSearchFor brand: FindBrandViewModel.Brand) {
        didToggleSearchBrand.send(brand)
    }
}


//MARK: - Set UI
private extension FindBrandVC {
    func makeUI() {
        navigationItem.title = "검색 브랜드"
        
        configureCollectionView()
        setConstraints()
    }
    
    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
