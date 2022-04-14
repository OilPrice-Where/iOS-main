//
//  MainListVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import NMapsMap
import SCLAlertView

protocol MainListVCDelegate: AnyObject {
    func touchedCell(info: GasStation)
}
//MARK: GasStationListVC
final class MainListVC: CommonViewController {
    //MARK: - Properties
    let infoView = InfoListView()
    var viewModel: MainListViewModel!
    weak var delegate: MainListVCDelegate?
    private var notiObject: NSObjectProtocol?
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .clear
        $0.dataSource = self
        $0.delegate = self
        GasStationCell.register($0)
    }
    
    private var noneView = MainListNoneView().then {
        $0.isHidden = true
    }
    
    //MARK: - Life Cycle
    deinit {
        if let noti = notiObject { NotificationCenter.default.removeObserver(noti) }
        notiObject = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.navigationBar.isHidden = false
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Set UI
    private func makeUI() {
        navigationItem.title = "주유소 목록"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(infoView)
        view.addSubview(collectionView)
        view.addSubview(noneView)
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(30)
        }
        collectionView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        noneView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        flowLayout.itemSize = CGSize(width: itemWidth, height: 168.0)
        
        flowLayout.invalidateLayout()
    }
    
    //MARK: - Rx Binding..
    private func rxBind() {
        // Sorted by Price/Distance
        infoView.priceSortedButton
            .rx
            .tap
            .bind(with: self, onNext: { owner, _ in
                owner.sortButtonTapped(btn: nil)
            })
            .disposed(by: bag)
        infoView.distanceSortedButton
            .rx
            .tap
            .bind(with: self, onNext: { owner, _ in
                owner.sortButtonTapped(btn: nil)
            })
            .disposed(by: bag)
        DefaultData.shared.completedRelay
            .observe(on: MainScheduler.asyncInstance)
            .subscribe(with: self, onNext: { owner, _ in
                owner.collectionView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    //MARK: - Method
    private func configure() {
        notiObject = NotificationCenter.default.addObserver(forName: NSNotification.Name("stationsUpdated"),
                                                            object: nil,
                                                            queue: .main) { [weak self] noti in
            guard let stations = noti.userInfo?["stations"] as? [GasStation] else { return }
            self?.viewModel.stations = stations
            self?.collectionView.reloadData()
        }
        
        noneView.isHidden = !viewModel.stations.isEmpty
        
        infoView.priceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
        infoView.distanceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
    }
    
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let screenWidth = UIScreen.main.bounds.width - 32
        let itemWidth = UIDevice.current.userInterfaceIdiom == .phone ? screenWidth : screenWidth / 2 - 6
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 12
        flowLayout.minimumInteritemSpacing = 12
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = CGSize(width: itemWidth, height: 163.2)
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        return flowLayout
    }
    
    @objc
    private func sortButtonTapped(btn: UIButton?) {
        guard let text = btn?.titleLabel?.text else { return }
        
        let isPriceSorted = text == "가격순"
        
        infoView.priceSortedButton.isSelected = isPriceSorted
        infoView.distanceSortedButton.isSelected = !isPriceSorted
        
        if isPriceSorted {
            infoView.priceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
            infoView.distanceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        } else {
            infoView.priceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.regular.font(size: 16)
            infoView.distanceSortedButton.titleLabel?.font = FontFamily.NanumSquareRound.extraBold.font(size: 16)
        }
        
        viewModel.sortedList(isPrice: isPriceSorted)
        
        collectionView.reloadData()
    }
}

//MARK: - TableViewDataSources & Delegate
extension MainListVC: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.stations.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: GasStationCell.id, for: indexPath) as? GasStationCell else { return UICollectionViewCell() }
        
        cell.configure(station: viewModel.stations[indexPath.item], indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
}

extension MainListVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.touchedCell(info: viewModel.stations[indexPath.item])
        navigationController?.popViewController(animated: true)
    }
}

extension MainListVC: GasStationCellDelegate {
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
        
        DefaultData.shared.favoriteSubject.accept(newFaovorites)
    }
    
    func touchedDirectionButton(info: GasStation?) {
        requestDirection(station: info)
    }
}

// HeaderView 설정
//func fetchAverageCosts() {
//    firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
//        self.gasolineCostLabel.text = data["price"] as? String ?? ""
//        self.gasolineTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.gasolineUpDownImageView.image = Asset.Images.priceUpIcon.image
//        }else {
//            self.gasolineUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//    }
//    firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
//        self.dieselCostLabel.text = data["price"] as? String ?? ""
//        self.dieselTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.dieselUpDownImageView.image = Asset.Images.priceUpIcon.image
//        }else {
//            self.dieselUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//
//    }
//    firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
//        self.lpgCostLabel.text = data["price"] as? String ?? ""
//        self.lpgTitleLabel.text = data["productName"] as? String ?? ""
//        if data["difference"] as? Bool ?? true {
//            self.lpgUpDownImageView.image = Asset.Images.priceUpIcon.image
//        } else {
//            self.lpgUpDownImageView.image = Asset.Images.priceDownIcon.image
//        }
//    }
//}
