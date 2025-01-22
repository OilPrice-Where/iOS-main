//
//  SearchBarVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


protocol SearchBarDelegate: AnyObject {
    func search(poi: SearchPOI)
}


//MARK: SearchBarVC
final class SearchBarVC: CommonViewController {
    //MARK: - Properties
    weak var delegate: SearchBarDelegate?
    
    private let viewModel: SearchBarViewModel
    
    private let didTapSearchPOI = PassthroughSubject<SearchPOI, Never>()
    private let didTapDeleteSearchPOI = PassthroughSubject<SearchPOI, Never>()
    private let didConfirmRemoveAllPOI = PassthroughSubject<Void, Never>()
    
    private let recentResultView = RecentResultView()
    private let searchResultView = SearchResultView()
    private let navigationView = CommonNavigationView().then {
        $0.titleLabel.text = UIConstants.NavigationView.title
    }
    private let searchImageView = UIImageView().then {
        $0.image = UIConstants.SearchImageView.image
        $0.tintColor = .systemGray5
    }
    private let searchBarView = CommonTextFieldView(
        titleWidth: UIConstants.SearchBarView.titleWidth,
        contentTrailing: UIConstants.SearchBarView.contentTrailing
    ).then {
        $0.contentTextField.clearButtonMode = .always
        $0.contentTextField.attributedPlaceholder = NSAttributedString(
            string: UIConstants.SearchBarView.content,
            attributes: [
                .foregroundColor: UIColor.systemGray4,
                .font: UIConstants.SearchBarView.contentFont
            ]
        )
    }
    private let titleLabel = UILabel().then {
        $0.text = UIConstants.TitleLabel.text
        $0.font = UIConstants.TitleLabel.font
    }
    private let removeAllButton = UIButton().then {
        $0.setTitle(UIConstants.RemoveAllButton.title, for: .normal)
        $0.setTitleColor(.systemGray, for: .normal)
        $0.titleLabel?.font = UIConstants.RemoveAllButton.font
    }
    private let emptyRecentSearchLabel = UILabel().then {
        $0.text = UIConstants.EmptyRecentSearchLabel.text
        $0.textColor = .systemGray
        $0.textAlignment = .center
        $0.font = UIConstants.EmptyRecentSearchLabel.font
    }
    
    
    //MARK: - Life Cycle
    init(viewModel: SearchBarViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configureRecentResultView()
        configureSearchResultView()
        bindActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = true
        searchBarView.contentTextField.becomeFirstResponder()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        
        view.endEditing(true)
    }
}


//MARK: - Binding..
private extension SearchBarVC {
    func bindActions() {
        removeAllButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.presentClearSearchHistoryAlert()
            }
            .store(in: &cancellable)
        
        navigationView.backButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellable)
        
        let output = viewModel.transform(input: .init(
            viewDidLoad: Just(()).eraseToAnyPublisher(),
            inputSearchText: searchBarView.contentTextField.textPublisher.eraseToAnyPublisher(),
            didTapPOI: didTapSearchPOI.eraseToAnyPublisher(),
            didTapDeletePOI: didTapDeleteSearchPOI.eraseToAnyPublisher(),
            didTapRemoveAllPOI: didConfirmRemoveAllPOI.eraseToAnyPublisher()
        ))
        
        bindUI(output: output)
    }
    
    func bindUI(output: SearchBarViewModel.Output) {
        output.recentSearchResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] searchPOIs in
                self?.emptyRecentSearchLabel.isHidden = searchPOIs.isNotEmpty
                self?.recentResultView.apply(pois: searchPOIs)
            }
            .store(in: &cancellable)
        
        output.searchKeywordResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.searchResultView.isHidden = items.isEmpty
                self?.searchResultView.apply(items: items)
            }
            .store(in: &cancellable)
        
        output.selectedPOIResult
            .receive(on: DispatchQueue.main)
            .sink { [weak self] poi in
                self?.delegate?.search(poi: poi)
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &cancellable)
        
        searchBarView.contentTextField
            .didBeginEditingPublisher
            .receive(on: DispatchQueue.main)
            .map { UIColor.systemGray }
            .assign(to: \.tintColor, on: searchImageView)
            .store(in: &cancellable)
        
        searchBarView.contentTextField
            .controlPublisher(for: .editingDidEnd)
            .receive(on: DispatchQueue.main)
            .map { _ in UIColor.systemGray4 }
            .assign(to: \.tintColor, on: searchImageView)
            .store(in: &cancellable)
        
        searchBarView.contentTextField
            .textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .map { $0.isEmpty }
            .assign(to: \.isHidden, on: searchResultView)
            .store(in: &cancellable)
    }
}


extension SearchBarVC: RecentResultViewDelegate {
    func didTapRecentResult(poi: SearchPOI) {
        didTapSearchPOI.send(poi)
    }
    
    func didTapDeleteRecentResult(poi: SearchPOI) {
        didTapDeleteSearchPOI.send(poi)
    }
    
    private func configureRecentResultView() {
        recentResultView.delegate = self
    }
    
    private func presentClearSearchHistoryAlert() {
        let alert = UIAlertController(
            title: "최근 검색어를 모두 삭제하시겠습니까?",
            message: nil,
            preferredStyle: .actionSheet
        )
        
        let deleteAction = UIAlertAction(
            title: "삭제",
            style: .destructive
        ) { [weak self] _ in
            self?.didConfirmRemoveAllPOI.send(())
        }
        let cancelAction = UIAlertAction(
            title: "취소",
            style: .cancel
        )
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}


extension SearchBarVC: SearchResultViewDelegate {
    func didTapSearchResult(poi: SearchPOI) {
        didTapSearchPOI.send(poi)
    }
    
    private func configureSearchResultView() {
        searchResultView.delegate = self
        searchResultView.isHidden = true
    }
}


//MARK: - Set UI
private extension SearchBarVC {
    enum UIConstants {
        enum NavigationView {
            static let title: String = "주소 검색"
            static let height: CGFloat = 47.0
        }
        
        enum SearchImageView {
            static let image: UIImage = Asset.Images.search.image.withRenderingMode(.alwaysTemplate)
            
            static let leftOffset: CGFloat = 10
            static let size: CGFloat = 20
        }
        
        enum SearchBarView {
            static let content: String = "주유소 위치를 검색해보세요."
            static let contentFont: UIFont = FontFamily.NanumSquareRound.regular.font(size: 12)
            static let titleWidth: CGFloat = 0.1
            static let contentTrailing: CGFloat = 8
            
            static let topOffset: CGFloat = 16
            static let horizontalInsets: CGFloat = 16
            static let height: CGFloat = 42
        }
        
        enum TitleLabel {
            static let text: String = "최근 검색"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 14)
            
            static let topOffset: CGFloat = 24
            static let leftOffset: CGFloat = 16
        }
        
        enum RemoveAllButton {
            static let title: String = "전체 삭제"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 12)
            
            static let rightOffset: CGFloat = -16
        }
        
        enum EmptyRecentSearchLabel {
            static let text: String = "최근 검색한 내역이 없습니다"
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 18)
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.backgroundColor = .white
        
        view.addSubview(navigationView)
        view.addSubview(searchBarView)
        view.addSubview(searchImageView)
        view.addSubview(titleLabel)
        view.addSubview(removeAllButton)
        view.addSubview(recentResultView)
        view.addSubview(emptyRecentSearchLabel)
        view.addSubview(searchResultView)
    }
    
    func setConstraints() {
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIConstants.NavigationView.height)
        }
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(UIConstants.SearchBarView.topOffset)
            $0.horizontalEdges.equalToSuperview().inset(UIConstants.SearchBarView.horizontalInsets)
            $0.height.equalTo(UIConstants.SearchBarView.height)
        }
        searchImageView.snp.makeConstraints {
            $0.left.equalTo(searchBarView.snp.left).offset(UIConstants.SearchImageView.leftOffset)
            $0.centerY.equalTo(searchBarView)
            $0.size.equalTo(UIConstants.SearchImageView.size)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(UIConstants.TitleLabel.topOffset)
            $0.left.equalToSuperview().inset(UIConstants.TitleLabel.leftOffset)
        }
        removeAllButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().offset(UIConstants.RemoveAllButton.rightOffset)
        }
        recentResultView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom)
            $0.left.bottom.right.equalToSuperview()
        }
        emptyRecentSearchLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        searchResultView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom)
            $0.horizontalEdges.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
