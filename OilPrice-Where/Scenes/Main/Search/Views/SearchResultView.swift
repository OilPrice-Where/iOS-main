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
}


//MARK: - CollectionView
extension SearchResultView: UICollectionViewDelegate {
    private final class SearchResultDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, SearchPOI> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, SearchPOI>
        
        func applySnapshot(with pois: [SearchPOI],
                           animatingDifferences: Bool = false) {
            var snapshot: Snapshot = .init()
            snapshot.appendItems(pois, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    private func configureCollectionView() {
        var configuration = UICollectionLayoutListConfiguration(appearance: .plain)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.keyboardDismissMode = .onDrag
            $0.alwaysBounceVertical = false
            $0.alwaysBounceHorizontal = false
            $0.showsHorizontalScrollIndicator = false
        }
        
        configureDataSource()
    }
    
    private func configureDataSource() {
        self.dataSource = SearchResultDataSource(collectionView: collectionView) { collectionView, indexPath, poi in
            let cellRegistration = SearchResultCell.cellRegistration(searchText: "")
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: poi
            )
        }
    }
    
    func apply(pois: [SearchPOI]) {
        dataSource.applySnapshot(with: pois)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let poi = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        delegate?.didTapSearchResult(poi: poi)
    }
}


//MARK: - Set UI
private extension SearchResultView {
    enum UIConstants {
        enum CollectionView {
            static let topOffset: CGFloat = 8
            static let horizontalInsets: CGFloat = 16
            static let bottomOffset: CGFloat = -16
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
