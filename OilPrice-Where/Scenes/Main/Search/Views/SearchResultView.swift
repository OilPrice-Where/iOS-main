//
//  SearchResultView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 1/31/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import SnapKit


protocol SearchResultViewDelegate: AnyObject {
    func didTapSearchResult(poi: SearchPOI)
}


final class SearchResultView: UIView {
    weak var delegate: SearchResultViewDelegate?
    
    private var collectionView: UICollectionView!
    private var dataSource: SearchResultDataSource!
    
    
    init() {
        super.init(frame: .zero)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - CollectionView
extension SearchResultView: UICollectionViewDelegate {
    private final class SearchResultDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, SearchBarViewModel.SearchResultItem> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, SearchBarViewModel.SearchResultItem>
        
        func applySnapshot(with items: [SearchBarViewModel.SearchResultItem],
                           animatingDifferences: Bool = false) {
            var snapshot: Snapshot = .init()
            snapshot.appendSections([.main])
            snapshot.appendItems(items, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    private func configureCollectionView() {
        let layout = collectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.keyboardDismissMode = .onDrag
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        configureDataSource()
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = .zero
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = UIConstants.CollectionView.itemSize
        flowLayout.sectionInset = .zero
        return flowLayout
    }
    
    private func configureDataSource() {
        let cellRegistration = SearchResultCell.cellRegistration
        self.dataSource = SearchResultDataSource(collectionView: collectionView) { collectionView, indexPath, item in
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: item
            )
        }
    }
    
    func apply(items: [SearchBarViewModel.SearchResultItem]) {
        dataSource.applySnapshot(with: items)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        delegate?.didTapSearchResult(poi: item.poi)
    }
}


//MARK: - Set UI
private extension SearchResultView {
    enum UIConstants {
        enum CollectionView {
            static let topOffset: CGFloat = 8
            static let horizontalInsets: CGFloat = 16
            static let bottomOffset: CGFloat = -16
            
            static let itemSize: CGSize = .init(
                width: UIScreen.screenWidth - (horizontalInsets * 2),
                height: 86
            )
        }
    }
    
    func makeUI() {
        configureCollectionView()
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(collectionView)
    }
    
    func setConstraints() {
        collectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.CollectionView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.CollectionView.horizontalInsets)
            $0.bottom.equalToSuperview().offset(UIConstants.CollectionView.bottomOffset)
        }
    }
}
