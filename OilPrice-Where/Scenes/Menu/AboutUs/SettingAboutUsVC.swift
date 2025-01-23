//
//  SettingAboutUsVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


//MARK: SettingAboutUsVC
final class SettingAboutUsVC: CommonViewController {
    
    //MARK: - Properties
    let viewModel: SettingAboutUsViewModel
    
    private var collectionView: UICollectionView!
    private var dataSource: SettingAboutUsDataSource!
    
    private let didSelectItemPublisher = PassthroughSubject<SettingAboutUsViewModel.AboutMe, Never>()
    
    //MARK: - Life Cycle
    init(viewModel: SettingAboutUsViewModel) {
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

private extension SettingAboutUsVC {
    func bindUI() {
        viewModel.aboutUsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] aboutUs in
                self?.dataSource.applySnapshot(with: aboutUs)
            }
            .store(in: &cancellable)
    }
    
    func bindActions() {
        let output = viewModel.transform(input: .init(
            didSelectItem: didSelectItemPublisher.eraseToAnyPublisher()
        ))
        
        output.openLink
            .receive(on: DispatchQueue.main)
            .sink { targetUrl in
                guard UIApplication.shared.canOpenURL(targetUrl) else {
                    return
                }
                UIApplication.shared.open(targetUrl, options: [:], completionHandler: nil)
            }
            .store(in: &cancellable)
    }
}


//MARK: - Set UI
private extension SettingAboutUsVC {
    final class SettingAboutUsDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, SettingAboutUsViewModel.AboutMe> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, SettingAboutUsViewModel.AboutMe>
        
        func applySnapshot(with items: [SettingAboutUsViewModel.AboutMe],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendSections([.main])
            snapshot.appendItems(items, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    func makeUI() {
        navigationItem.title = "About Us"
        
        configureCollectionView()
        configureDataSource()
    }
    
    func configureCollectionView() {
        let configuration = UICollectionLayoutListConfiguration(appearance: .plain)
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
        let cellRegistration = AboutUsCell.cellRegistration
        self.dataSource = SettingAboutUsDataSource(collectionView: collectionView) { collectionView, indexPath, aboutMe in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: aboutMe)
        }
    }
}

extension SettingAboutUsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let aboutMe = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        
        didSelectItemPublisher.send(aboutMe)
    }
}
