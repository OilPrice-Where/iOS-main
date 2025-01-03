//
//  FrequentVisitVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


//MARK: 자주 방문한 List
final class FrequentVisitVC: CommonViewController {
    //MARK: - Properties
    let viewModel = FrequentVisitViewModel()
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        FrequentVisitCell.register($0)
    }
    private lazy var emptyLabel = UILabel().then {
        $0.text = "방문하신 주유소가 없습니다."
        $0.textColor = .darkGray
        $0.textAlignment = .center
        $0.isHidden = !DataManager.shared.stationList.isEmpty
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 18)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(collectionView)
        view.addSubview(emptyLabel)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        viewModel.output.stations
            .bind(subscriber: collectionView.itemsSubscriber(cellIdentifier: FrequentVisitCell.id,
                                                             cellType: FrequentVisitCell.self,
                                                             cellConfig: { cell, indexPath, station in
                cell.delegate = self
                cell.configure(station: station)
            }))
            .store(in: &viewModel.cancellable)
        
        DefaultData.shared.completedRelay
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let owner = self else { return }
                owner.collectionView.reloadData()
            }
            .store(in: &viewModel.cancellable)
        
        collectionView
            .didSelectItemPublisher
            .receive(on: DispatchQueue.main)
            .map { [weak self] indexPath in
                self?.collectionView.cellForItem(at: indexPath) as? FrequentVisitCell
            }
            .compactMap { $0?.info }
            .sink { [weak self] station in
                guard let self,
                      let id = station.identifier else { return }
                
                let settingStorage: SettingStorage = PlistSettingStorage()
                let settingUseCase: SettingUseCase = SettingUseCaseImpl(storage: settingStorage)
                let stationRepository: StationRepository = StationRepositoryImpl()
                let visitedStationStorage: VisitedStationStorage = CoreDataVisitedStationStorage()
                let detailViewModel = StationDetailViewModel(
                    stationID: id,
                    settingUseCase: settingUseCase,
                    stationRepository: stationRepository,
                    visitedStationStorage: visitedStationStorage
                )
                let detailVC = StationDetailVC(viewModel: detailViewModel)
                navigationController?.pushViewController(detailVC, animated: true)
            }
            .store(in: &viewModel.cancellable)
        
        DataManager.shared.stationListIsEmpty
            .map { !$0 }
            .assign(to: \.isHidden, on: emptyLabel)
            .store(in: &viewModel.cancellable)
    }
    
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 16
        flowLayout.minimumInteritemSpacing = 16
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: 139.2)
        flowLayout.sectionInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
        return flowLayout
    }
}

extension FrequentVisitVC: FrequentVisitCollectionViewCellDelegate {
    // 즐겨찾기 설정 및 해제
    func touchedFavoriteButton(id: String?) {
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = id, faovorites.count < 6 else { return }
        let isDeleted = faovorites.contains(_id)
        guard isDeleted || (!isDeleted && faovorites.count < 5) else {
            DispatchQueue.main.async { [weak self] in
                self?.makeAlert(title: "최대 5개까지 추가 가능합니다", subTitle: "이전 즐겨찾기를 삭제하고 추가해주세요 !")
            }
            return
        }
        var newFaovorites = faovorites
        isDeleted ? newFaovorites = newFaovorites.filter { $0 != _id } : newFaovorites.append(_id)
        
        DefaultData.shared.favoriteSubject.send(newFaovorites)
        
        let msg = isDeleted ? "즐겨 찾는 주유소가 삭제되었습니다." : "즐겨 찾는 주유소에 추가되었습니다."
        let lbl = Preferences.showToast(width: 240, message: msg, numberOfLines: 1)
        view.hideToast()
        view.showToast(lbl, position: .top)
    }
    
    func touchedDirectionButton(info: StationEntity?) {
        guard let target = info else { return }
        
        let station = GasStationSummary(
            id: target.identifier ?? UUID().uuidString,
            brand: .init(code: target.brand ?? ""),
            name: target.name ?? "",
            price: .zero,
            distance: .zero,
            coordinate: .init(x: target.katecX, y: target.katecY)
        )
        requestDirection(station: station)
    }
}
