//
//  MainListVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/01.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import TMapSDK
import NMapsMap
import SCLAlertView

protocol MainListVCDelegate: AnyObject {
    func touchedCell(info: GasStation)
}

//MARK: GasStationListVC
final class MainListVC: CommonViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    var viewModel: MainListViewModel!
    weak var delegate: MainListVCDelegate?
    lazy var tableView = UITableView().then {
        $0.separatorStyle = .none
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = .systemGroupedBackground
        $0.dataSource = self
        $0.delegate = self
        GasStationCell.register($0)
    }
    let infoView = InfoListView()
    var noneView = MainListNoneView().then {
        $0.isHidden = true
    }
    
    //MARK: - Life Cycle
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
    
    //MARK: - Make UI
    func makeUI() {
        navigationItem.title = "주유소 목록"
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.backgroundColor = Asset.Colors.mainColor.color
        navigationController?.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                   .foregroundColor: UIColor.white]
        
        view.backgroundColor = .systemGroupedBackground
        
        view.addSubview(infoView)
        view.addSubview(tableView)
        view.addSubview(noneView)
        
        infoView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(30)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(infoView.snp.bottom)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        noneView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide)
            $0.left.bottom.right.equalToSuperview()
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
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
                owner.tableView.reloadData()
            })
            .disposed(by: rx.disposeBag)
    }
    
    func configure() {
        infoView.priceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
        infoView.distanceSortedButton.addTarget(self, action: #selector(sortButtonTapped(btn:)), for: .touchUpInside)
    }
    
    @objc
    func sortButtonTapped(btn: UIButton?) {
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
        
        tableView.reloadData()
    }
    
    func handleError(error: Error?) {
        guard let error = error as NSError? else { return }
        
        let alert = UIAlertController(title: title,
                                      message: error.localizedFailureReason,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "확인", style: .cancel, handler: nil)
        alert.addAction(okAction)
        
        present(alert, animated: true, completion: nil)
    }
}

//MARK: - TableViewDataSources & Delegate
extension MainListVC: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.stations.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: GasStationCell.id, for: indexPath) as? GasStationCell else { return UITableViewCell() }
        
        cell.configure(station: viewModel.stations[indexPath.section], indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
}

extension MainListVC: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.touchedCell(info: viewModel.stations[indexPath.section])
        navigationController?.popViewController(animated: true)
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 163.2
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 12
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 12))
        view.backgroundColor = .systemGroupedBackground
        return view
    }
}

extension MainListVC: GasStationCellDelegate {
    // 즐겨찾기 설정 및 해제
    func touchedFavoriteButton(id: String?, indexPath: IndexPath?) {
        let faovorites = DefaultData.shared.favoriteSubject.value
        guard let _id = id, let _indexPath = indexPath, faovorites.count < 6 else { return }
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
        tableView.reloadRows(at: [_indexPath], with: .none)
    }
    
    func touchedDirectionButton(info: GasStation?) {
        guard let info = info,
              let type = NaviType(rawValue: DefaultData.shared.naviSubject.value) else { return }
        
        let position = NMGTm128(x: info.katecX, y: info.katecY).toLatLng()
        
        switch type {
        case .tMap:
            if TMapApi.isTmapApplicationInstalled() {
                let _ = TMapApi.invokeRoute(info.name,
                                            coordinate: CLLocationCoordinate2D(latitude: position.lat,
                                                                               longitude: position.lng))
                return
            }
            
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인",
                                         style: .default) { _ in
                guard let url = URL(string: TMapApi.getTMapDownUrl()),
                      UIApplication.shared.canOpenURL(url) else { return }
                
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
            
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
        case .kakao:
            let destination = KNVLocation(name: info.name,
                                          x: NSNumber(value: info.katecX),
                                          y: NSNumber(value: info.katecY))
            let options = KNVOptions()
            options.routeInfo = false
            let params = KNVParams(destination: destination,
                                   options: options)
            KNVNaviLauncher.shared().navigate(with: params) { [weak self] (error) in
                DispatchQueue.main.async {
                    self?.handleError(error: error)
                }
            }
        case .kakaoMap:
            guard let destinationURL = URL(string: "kakaomap://route?ep=\(position.lat),\(position.lng)&by=CAR"),
                  let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/304608425") else { return }
            
            if UIApplication.shared.canOpenURL(destinationURL) {
                UIApplication.shared.open(destinationURL, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.open(appstoreURL, options: [:], completionHandler: nil)
            }
        case .naver:
            let urlString = "nmap://navigation?dlat=\(position.lat)&dlng=\(position.lng)&dname=\(info.name)&appname=com.oilpricewhere.wheregasoline"
            
            guard let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let destinationURL = URL(string: encodedStr),
                  let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/311867728") else { return }
            
            if UIApplication.shared.canOpenURL(destinationURL) {
                UIApplication.shared.open(destinationURL)
            } else {
                UIApplication.shared.open(appstoreURL, options: [:], completionHandler: nil)
            }
        }
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
