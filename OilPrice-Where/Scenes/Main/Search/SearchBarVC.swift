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
    func fetch(name: String?, coordinate: CLLocationCoordinate2D?)
}


//MARK: SearchBarVC
final class SearchBarVC: CommonViewController {
    //MARK: - Properties
    weak var delegate: SearchBarDelegate?
    
    private let viewModel: SearchBarViewModel
    
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        configureSearchResultView()
        bind()
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
    
    //MARK: - Rx Binding..
    private func bind() {
        searchBarView
            .contentTextField
            .textPublisher
            .receive(on: DispatchQueue.global())
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] text in
                self?.viewModel.input.requestPOI.send(text)
            }
            .store(in: &viewModel.bag)
        searchBarView
            .contentTextField
            .didBeginEditingPublisher
            .receive(on: DispatchQueue.main)
            .map { UIColor.systemGray }
            .assign(to: \.tintColor, on: searchImageView)
            .store(in: &viewModel.bag)
        
        searchBarView.contentTextField
            .controlPublisher(for: .editingDidEnd)
            .receive(on: DispatchQueue.main)
            .map { _ in UIColor.systemGray4 }
            .assign(to: \.tintColor, on: searchImageView)
            .store(in: &viewModel.bag)
        
        searchBarView
            .contentTextField
            .textPublisher
            .receive(on: DispatchQueue.main)
            .compactMap { $0 }
            .filter { $0.count == 0 }
            .map { $0.isEmpty }
            .assign(to: \.isHidden, on: searchResultTableView)
            .store(in: &viewModel.bag)
        
        removeAllButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                let alert = UIAlertController(title: "최근 검색어를 모두 삭제하시겠습니까?", message: nil, preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { _ in
                    for poi in DataManager.shared.pois {
                        DataManager.shared.delete(value: poi)
                    }
                    DataManager.shared.pois.removeAll()
                    
                    self?.performRecentDataSnapShot()
                }
                
                let cancelAction = UIAlertAction(title: "취소", style: .cancel)
                
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                
                self?.present(alert, animated: true)
            }
            .store(in: &viewModel.bag)
        
        viewModel
            .output
            .resultPOIs
            .receive(on: DispatchQueue.main)
            .sink {
                if case let .failure(error) = $0 {
                    LogUtil.e(error.localizedDescription)
                }
            } receiveValue: { [weak self] in
                self?.viewModel.pois = $0
                self?.searchResultTableView.isHidden = $0.isEmpty
                self?.performSearchDataSnapShot(pois: $0)
            }
            .store(in: &viewModel.bag)
        
        navigationView.backButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.navigationController?.popViewController(animated: true)
            }
            .store(in: &viewModel.bag)
        
        DataManager.shared.$poisIsNotEmpty
            .receive(on: DispatchQueue.main)
            .assign(to: \.isHidden, on: emptyRecentSearchLabel)
            .store(in: &bag)
    }
    
    @objc
    private func backButtonTouched() {
        navigationController?.popViewController(animated: true)
    }
}

//MARK:- DiffDataSource
extension SearchBarVC: UITableViewDelegate {
    private func performRecentDataSource() {
        recentDataSource = UITableViewDiffableDataSource<Section, ResponsePOI>(tableView: recentTableView, cellProvider: { tableView, indexPath, poi in
            let cell = tableView.dequeueReusableCell(withType: RecentResultCell.self, for: indexPath)
            
            cell.configure(with: poi, index: indexPath.row)
            cell.delegate = self
            
            return cell
        })
    }
    
    private func performRecentDataSnapShot() {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ResponsePOI>()
        snapshot.appendSections([.search])
        
        let pois = DataManager.shared.pois.map {
            ResponsePOI(name: $0.name,
                        address: $0.address,
                        coordinate: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude),
                        insertDate: $0.insertDate)
        }
        
        snapshot.appendItems(pois)
        self.recentDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        navigationController?.popViewController(animated: true)
    }
}

extension SearchBarVC: RecentResultCellProtocol {
    func delete(poi: POIEntity?, index: Int?) {
        guard let poi, let index else { return }
        
        DataManager.shared.delete(value: poi)
        DataManager.shared.pois.remove(at: index)
        
        performRecentDataSnapShot()
    }
}

extension SearchBarVC: SearchResultViewDelegate {
    func didTapSearchResult(poi: ResponsePOI) {
        
    }
    
    private func configureSearchResultView() {
        searchResultView.delegate = self
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
        view.addSubview(recentTableView)
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
        recentTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.bottom.right.equalToSuperview().inset(16)
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
