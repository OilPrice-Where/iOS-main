//
//  RecentResultView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 1/31/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import SnapKit


protocol RecentResultViewDelegate: AnyObject {
    func didTapRecentResult(poi: SearchPOI)
    func didTapDeleteRecentResult(poi: SearchPOI)
}


final class RecentResultView: UIView {
    weak var delegate: RecentResultViewDelegate?
    
    private var collectionView: UICollectionView!
    private var dataSource: RecentResultDataSource!
}


//MARK: - CollectionView
extension RecentResultView: UICollectionViewDelegate {
    private final class RecentResultDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, SearchPOI> {
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
        self.dataSource = RecentResultDataSource(collectionView: collectionView) { collectionView, indexPath, poi in
            let cellRegistration = RecentResultCell.cellRegistration(self)
            return collectionView.dequeueConfiguredReusableCell(
                using: cellRegistration,
                for: indexPath,
                item: poi
            )
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let poi = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        delegate?.didTapRecentResult(poi: poi)
    }
}


extension RecentResultView: RecentResultCellDelegate {
    func delete(poi: SearchPOI) {
        delegate?.didTapDeleteRecentResult(poi: poi)
    }
}


//MARK: - Set UI
private extension RecentResultView {
    enum UIConstants {
        enum CollectionView {
            static let insets: CGFloat = 16
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
            $0.edges.equalToSuperview().inset(UIConstants.CollectionView.insets)
        }
    }
}
