//
//  SettingEditSalePriceVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/12.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
//MARK: 카드 할인 VC
final class SettingEditSalePriceVC: UIViewController, ViewModelBindableType {
    //MARK: - Properties
    var viewModel: EditSalePriceViewModel!
    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: fetchLayout()).then {
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.decelerationRate = UIScrollViewDecelerationRateFast
        $0.alwaysBounceHorizontal = false
        $0.allowsMultipleSelection = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        CardCollectionViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prefences()
        makeUI()
    }
    
    //MARK: - Rx Binding..
    func bindViewModel() {
        
    }
    
    //MARK: - Set UI
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubview(collectionView)
        
        collectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func prefences() {
        let item = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(toCreateCard))
        
        navigationItem.title = "카드 할인"
        navigationItem.rightBarButtonItem = item
    }
    
    // set collectionView flow layout
    private func fetchLayout() -> UICollectionViewFlowLayout {
        let itemWidth = fetchItemWidth()
        let itemSize = CGSize(width: itemWidth, height: itemWidth * 0.6)
        
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 25
        flowLayout.minimumInteritemSpacing = .zero
        flowLayout.scrollDirection = .vertical
        flowLayout.itemSize = itemSize
        flowLayout.sectionInset = UIEdgeInsets(top: 37.5, left: 0, bottom: 37.5, right: 0)
        return flowLayout
    }
    
    private func fetchItemWidth() -> CGFloat {
        let screenWidth = UIScreen.main.bounds.width - 75
        let current = UIDevice.current
        return current.userInterfaceIdiom == .phone ? screenWidth : current.orientation == .portrait ? screenWidth / 2 - 12.5 : screenWidth / 3 - (50 / 3)
    }
    
    @objc
    private func toCreateCard() {
        let addCardVC = AddCardVC()
        navigationController?.pushViewController(addCardVC, animated: true)
    }
}

extension SettingEditSalePriceVC: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withType: CardCollectionViewCell.self, indexPath: indexPath)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.bounds
        gradientLayer.colors = [viewModel.tColors[indexPath.row].cgColor,
                                viewModel.bColors[indexPath.row].cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        cell.containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        return cell
    }
}
