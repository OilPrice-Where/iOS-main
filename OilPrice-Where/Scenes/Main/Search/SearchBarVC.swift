//
//  SearchBarVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import Combine
import CoreLocation
import CombineCocoa

protocol SearchBarDelegate: AnyObject {
    func fetch(name: String?, coordinate: CLLocationCoordinate2D?)
}

//MARK: SearchBarVC
final class SearchBarVC: CommonViewController {
    //MARK: - Properties
    enum Section {
        case search
    }
    var bag = Set<AnyCancellable>()
    weak var delegate: SearchBarDelegate?
    private let viewModel = SearchBarViewModel()
    let navigationView = CommonNavigationView().then {
        $0.titleLabel.text = "주소 검색"
    }
    let searchImageView = UIImageView().then {
        $0.image = Asset.Images.search.image.withRenderingMode(.alwaysTemplate)
        $0.tintColor = .systemGray5
    }
    let searchBarView = CommonTextFieldView(titleWidth: 0.1, contentTrailing: 8.0).then {
        $0.contentTextField.clearButtonMode = .always
        $0.contentTextField.attributedPlaceholder = NSAttributedString(string: "주유소 위치를 검색해보세요.", attributes: [
            .foregroundColor: UIColor.systemGray4,
            .font: FontFamily.NanumSquareRound.regular.font(size: 12)
        ])
    }
    let titleLabel = UILabel().then {
        $0.text = "최근 검색"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 14)
    }
    let removeAllButton = UIButton().then {
        $0.setTitle("전체 삭제", for: .normal)
        $0.setTitle("전체 삭제", for: .highlighted)
        $0.setTitleColor(.systemGray, for: .normal)
        $0.setTitleColor(.systemGray, for: .highlighted)
        $0.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 12)
    }
    lazy var recentTableView = UITableView().then {
        $0.delegate = self
        $0.separatorStyle = .none
        $0.separatorColor = .clear
        $0.keyboardDismissMode = .onDrag
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        RecentResultCell.register($0)
    }
    lazy var searchResultTableView = UITableView().then {
        $0.isHidden = true
        $0.delegate = self
        $0.separatorStyle = .none
        $0.separatorColor = .clear
        $0.keyboardDismissMode = .onDrag
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        SearchResultCell.register($0)
    }
    let emptyRecentSearchLabel = UILabel().then {
        $0.text = "최근 검색한 내역이 없습니다"
        $0.textColor = .systemGray
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
        $0.isHidden = true
    }
    
    var searchDataSource: UITableViewDiffableDataSource<Section, ResponsePOI>?
    var recentDataSource: UITableViewDiffableDataSource<Section, ResponsePOI>?
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
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
    
    //MARK: - Make UI
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubview(navigationView)
        view.addSubview(searchBarView)
        view.addSubview(searchImageView)
        view.addSubview(titleLabel)
        view.addSubview(removeAllButton)
        view.addSubview(recentTableView)
        view.addSubview(emptyRecentSearchLabel)
        view.addSubview(searchResultTableView)
        
        navigationView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(47)
        }
        searchBarView.snp.makeConstraints {
            $0.top.equalTo(navigationView.snp.bottom).offset(16)
            $0.left.right.equalToSuperview().inset(16)
            $0.height.equalTo(42)
        }
        searchImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.left.equalTo(searchBarView.snp.left).offset(10)
            $0.centerY.equalTo(searchBarView)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(24)
            $0.left.equalToSuperview().inset(16)
        }
        removeAllButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel.snp.centerY)
            $0.right.equalToSuperview().inset(16)
        }
        recentTableView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.left.bottom.right.equalToSuperview().inset(16)
        }
        emptyRecentSearchLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        searchResultTableView.snp.makeConstraints {
            $0.top.equalTo(searchBarView.snp.bottom).offset(8)
            $0.left.bottom.right.equalToSuperview().inset(16)
        }
        
        performRecentDataSource()
        performSearchDataSource()
        performRecentDataSnapShot()
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
        
        searchBarView
            .contentTextField
            .controlEventPublisher(for: .editingDidEnd)
            .receive(on: DispatchQueue.main)
            .map { UIColor.systemGray4 }
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
    
    private func performSearchDataSource() {
        searchDataSource = UITableViewDiffableDataSource<Section, ResponsePOI>(tableView: searchResultTableView, cellProvider: { [weak self] tableView, indexPath, poi in
            let cell = tableView.dequeueReusableCell(withType: SearchResultCell.self, for: indexPath)
            
            let attrString = NSMutableAttributedString(string: poi.name ?? "")
            cell.titleLabel.attributedText = attrString.apply(word: self?.searchBarView.contentTextField.text ?? "",
                                                              attrs: [.foregroundColor: UIColor.black])
            cell.subTitleLabel.text = poi.address
            
            if let departure = LocationManager.shared.currentLocation,
               let targetCoordinate = poi.coordinate {
                let destination = CLLocation(latitude: targetCoordinate.latitude, longitude: targetCoordinate.longitude)
                
                let distance = departure.distance(from: destination)
                let distanceString = distance < 1000 ? "\(Int(distance))m" : "\(Double(Int(distance * 10 / 1000)) / 10)km"
                
                cell.distanceLabel.text = distanceString
            }
            
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
    
    private func performSearchDataSnapShot(pois: [ResponsePOI]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ResponsePOI>()
        snapshot.appendSections([.search])
        
        snapshot.appendItems(pois)
        self.searchDataSource?.apply(snapshot, animatingDifferences: false)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView == recentTableView ? 50 : 86
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView != recentTableView {
            DataManager.shared.addNew(poi: viewModel.pois[indexPath.row])
            delegate?.fetch(name: viewModel.pois[indexPath.row].name, coordinate: viewModel.pois[indexPath.row].coordinate)
        } else {
            let target = CLLocationCoordinate2D(latitude: DataManager.shared.pois[indexPath.row].latitude,
                                                longitude: DataManager.shared.pois[indexPath.row].longitude)
            delegate?.fetch(name: DataManager.shared.pois[indexPath.row].name, coordinate: target)
        }
        
        navigationController?.popViewController(animated: true)
    }
}

extension SearchBarVC: RecentResultCellProtocol {
    func delete(poi: POI?, index: Int?) {
        guard let poi, let index else { return }
        
        DataManager.shared.delete(value: poi)
        DataManager.shared.pois.remove(at: index)
        
        performRecentDataSnapShot()
    }
}
