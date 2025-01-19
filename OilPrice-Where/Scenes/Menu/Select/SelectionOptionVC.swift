//
//  SelectionOptionVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


final class SelectionOptionVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: SelectionOptionViewModel
    
    private let didSelectItem = PassthroughSubject<SelectionOptionViewModel.SelectionOption, Never>()
    
    private var collectionView: UICollectionView!
    private var dataSource: SelectionDataSource!
    private let backgroundView = UIView().then {
        $0.alpha = 0.0
        $0.backgroundColor = .black
    }
    private let containerView = UIView().then {
        $0.alpha = 0.0
        $0.layer.cornerRadius = 10.0
        $0.backgroundColor = .white
    }
    private let titleLabel = UILabel().then {
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
    }
    private let laterButton = UIButton().then {
        let att = NSAttributedString(
            string: "다음에 설정",
            attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]
        )
        $0.setAttributedTitle(att, for: .normal)
        $0.setAttributedTitle(att, for: .highlighted)
        $0.setTitleColor(.black, for: .normal)
        $0.setTitleColor(.black, for: .highlighted)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 14)
    }
    private let spacerView = UIView()
    
    //MARK: - Life Cycle
    init(viewModel: SelectionOptionViewModel) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.15) { [weak self] in
            self?.backgroundView.alpha = 0.65
            self?.containerView.alpha = 1.0
        }
    }
}


//MARK: - Binding..
private extension SelectionOptionVC {
    func bindUI() {
        viewModel.titlePublisher
            .receive(on: DispatchQueue.main)
            .assign(to: \.text, on: titleLabel)
            .store(in: &cancellable)
    }
    
    func bindActions() {
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            didSelectItem: didSelectItem.eraseToAnyPublisher(),
            laterButtonTapped: laterButton.tapPublisher.eraseToAnyPublisher(),
            backgroundViewTapped: backgroundView.gesturePublisher().map { _ in }.eraseToAnyPublisher()
        ))
        // 옵션 리스트 업데이트
        output.updateSelectionOptions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] options in
                self?.dataSource.applySnapshot(with: options)
            }
            .store(in: &cancellable)
        // => Dismiss VC
        output.dismiss
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.dismiss(animated: false)
            }
            .store(in: &cancellable)
        // => Dismiss Completion
        output.dismissWithSelectionResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] selectionResult in
                guard let self else {
                    return
                }
                
                dismiss(animated: false) {
                    // 이미 띄운 토스트가 있다면 hide
                    UIApplication.shared.customKeyWindow?.hideToast()
                    // 토스트 생성
                    let toast = Preferences.showToast(
                        width: selectionResult.toast.width,
                        message: selectionResult.toast.message,
                        subTitle: selectionResult.toast.subTitle
                    )
                    
                    UIApplication.shared.customKeyWindow?.showToast(
                        toast,
                        duration: 2.0,
                        position: .top
                    ) { _ in
                        guard let installURL = selectionResult.installURL,
                              UIApplication.shared.canOpenURL(installURL) else {
                            return
                        }
                        UIApplication.shared.open(installURL)
                    }
                }
            }
            .store(in: &cancellable)
    }
}


//MARK: - CollectionView
extension SelectionOptionVC: UICollectionViewDelegate {
    private final class SelectionDataSource: UICollectionViewDiffableDataSource<CommonDiffableSection, SelectionOptionViewModel.SelectionOption> {
        private typealias Snapshot = NSDiffableDataSourceSnapshot<CommonDiffableSection, SelectionOptionViewModel.SelectionOption>
        
        func applySnapshot(with options: [SelectionOptionViewModel.SelectionOption],
                           animatingDifferences: Bool = true) {
            var snapshot: Snapshot = .init()
            snapshot.appendSections([.main])
            snapshot.appendItems(options, toSection: .main)
            apply(snapshot, animatingDifferences: animatingDifferences)
        }
    }
    
    private func configureCollectionView() {
        let layout = collectionViewLayout()
        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout).then {
            $0.delegate = self
            $0.backgroundColor = .white
            $0.alwaysBounceHorizontal = false
            $0.allowsMultipleSelection = false
            $0.showsVerticalScrollIndicator = false
            $0.showsHorizontalScrollIndicator = false
        }
    }
    
    private func configureDataSource() {
        let cellRegistration = SelectionOptionCell.cellRegistration
        self.dataSource = SelectionDataSource(collectionView: collectionView) { collectionView, indexPath, option in
            collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: option)
        }
    }
    
    private func collectionViewLayout() -> UICollectionViewFlowLayout {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = UIConstants.CollectionView.lineSpacing
        layout.minimumInteritemSpacing = UIConstants.CollectionView.itemSpacing
        layout.itemSize = UIConstants.CollectionView.itemSize
        layout.sectionInset = .zero
        return layout
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let item = dataSource.itemIdentifier(for: indexPath) else {
            return
        }
        didSelectItem.send(item)
    }
}


//MARK: - Set UI
private extension SelectionOptionVC {
    enum UIConstants {
        enum ContainerView {
            static let widthRatio: CGFloat = 0.8
            static let height: CGFloat = 200 + CollectionView.height
        }
        
        enum TitleLabel {
            static let topOffset: CGFloat = 36.0
            static let horizontalPadding: CGFloat = 24.0
            static let height: CGFloat = 18.0
        }
        
        enum CollectionView {
            static let height: CGFloat = 272.0
            static let topOffset: CGFloat = 48.0
            static let horizontalPadding: CGFloat = 36.0
            static let lineSpacing: CGFloat = 24.0
            static let itemSpacing: CGFloat = 272.0
            static let itemSize: CGSize = .init(
                width: (UIScreen.main.bounds.width * 0.75) - 72,
                height: 50.0
            )
        }
        
        enum LaterButton {
            static let topOffset: CGFloat = 24.0
            static let horizontalPadding: CGFloat = 24.0
            static let size: CGSize = .init(width: 100, height: 50)
        }
        
        enum SpacerView {
            static let topOffset: CGFloat = 24.0
        }
    }
    
    func makeUI() {
        view.backgroundColor = .clear
        
        configureCollectionView()
        configureDataSource()
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.addSubview(backgroundView)
        view.addSubview(containerView)
        
        containerView.addSubview(titleLabel)
        containerView.addSubview(collectionView)
        containerView.addSubview(laterButton)
        containerView.addSubview(spacerView)
    }
    
    func setConstraints() {
        backgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(UIConstants.ContainerView.widthRatio)
            $0.height.equalTo(UIConstants.ContainerView.height)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(UIConstants.TitleLabel.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.TitleLabel.horizontalPadding)
            $0.height.equalTo(UIConstants.TitleLabel.height)
        }
        
        collectionView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(UIConstants.CollectionView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.CollectionView.horizontalPadding)
            $0.height.equalTo(UIConstants.CollectionView.height)
        }
        
        laterButton.snp.makeConstraints {
            $0.top.equalTo(collectionView.snp.bottom).offset(UIConstants.LaterButton.topOffset)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(UIConstants.LaterButton.size)
        }
        
        spacerView.snp.makeConstraints {
            $0.top.equalTo(laterButton.snp.bottom).offset(UIConstants.SpacerView.topOffset)
            $0.left.right.bottom.equalToSuperview()
        }
    }
}
