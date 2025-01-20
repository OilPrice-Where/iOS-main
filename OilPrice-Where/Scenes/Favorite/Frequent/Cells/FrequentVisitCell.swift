//
//  FrequentVisitCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


protocol FrequentVisitCellDelegate: AnyObject {
    /// 즐겨찾기 설정 및 해제
    func didTapFavoriteButton(station: VisitedGasStation)
    /// 길찾기 및 방문 주유소 저장
    func didTapDirectionButton(station: VisitedGasStation)
}


extension FrequentVisitCell {
    static func cellRegistration(_ delegate: FrequentVisitCellDelegate, settingUseCase: SettingUseCase) -> UICollectionView.CellRegistration<FrequentVisitCell, VisitedGasStation> {
        return UICollectionView.CellRegistration<FrequentVisitCell, VisitedGasStation> { cell, indexPath, visitStation in
            cell.delegate = delegate
            cell.configure(with: visitStation, settingUseCase: settingUseCase)
        }
    }
    
    // Configure Data
    private func configure(with station: VisitedGasStation, settingUseCase: SettingUseCase) {
        self.visitStation = station
        
        countLabel.text = "\(station.visitCount)회 방문"
        titleView.configure(title: station)
        
        if let favorites: [String] = try? settingUseCase.load(type: .favorites) {
            updateFavoriteUI(favorites: favorites)
        }
    }
}


final class FrequentVisitCell: UICollectionViewCell {
    //MARK: - Properties
    private var cancellable = Set<AnyCancellable>()
    
    private var visitStation: VisitedGasStation?
    weak var delegate: FrequentVisitCellDelegate?
    
    private let titleView = GasStationTitleView()
    private let expandView = GasStationExpandView()
    private let countLabel = UILabel().then {
        $0.textColor = .white
        $0.textAlignment = .center
        $0.backgroundColor = .lightGray
        $0.font = UIConstants.CountLabel.font
        $0.layer.cornerRadius = UIConstants.CountLabel.cornerRadius
        $0.clipsToBounds = true
    }
    private let lineView = UIView().then {
        $0.backgroundColor = UIConstants.LineView.backgroundColor
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cancellable.removeAll()
        bindActions()
    }
}

//MARK: - Bind
private extension FrequentVisitCell {
    func bindActions() {
        expandView.favoriteButton
            .tapPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                guard let self,
                      let visitStation else {
                    return
                }
                delegate?.didTapFavoriteButton(station: visitStation)
            }
            .store(in: &cancellable)
        
        expandView.directionView
            .gesturePublisher()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                guard let self,
                      let visitStation else {
                    return
                }
                delegate?.didTapDirectionButton(station: visitStation)
            }
            .store(in: &cancellable)
        
        NotificationCenter.default.publisher(for: SettingType.favorites.notificationName)
            .compactMap { $0.object as? [String] }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] favorites in
                guard let self else {
                    return
                }
                updateFavoriteUI(favorites: favorites)
            }
            .store(in: &cancellable)
    }
}



//MARK: - Set UI
private extension FrequentVisitCell {
    enum UIConstants {
        enum Cell {
            static let cornerRadius: CGFloat = 5.0
        }
        
        enum CountLabel {
            static let font = FontFamily.NanumSquareRound.extraBold.font(size: 10)
            static let cornerRadius: CGFloat = 5.0
            
            static let height: CGFloat = 20
            static let width: CGFloat = 60
        }
        
        enum TitleView {
            static let topOffset: CGFloat = 8
            static let leftOffset: CGFloat = 12
            static let rightOffset: CGFloat = -16
            static let height: CGFloat = 30
        }
        
        enum LineView {
            static let backgroundColor: UIColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
            
            static let topOffset: CGFloat = 8
            static let height: CGFloat = 1.2
        }
        
        enum ExpandView {
            static let favoriteOnTintColor: UIColor = .white
            static let favoriteOffTintColor: UIColor = Asset.Colors.mainColor.color
            static let favoriteOnBackgroundColor: UIColor = Asset.Colors.mainColor.color
            static let favoriteOffBackgroundColor: UIColor = .white
            
            static let topOffset: CGFloat = 16
            static let bottomOffset: CGFloat = -16
        }
    }
    
    func makeUI() {
        backgroundColor = .white
        layer.cornerRadius = UIConstants.Cell.cornerRadius
        
        configureUI()
        setConstraints()
        configureExpandView()
    }
    
    func configureUI() {
        contentView.addSubview(countLabel)
        contentView.addSubview(titleView)
        contentView.addSubview(expandView)
        contentView.addSubview(lineView)
    }
    
    func setConstraints() {
        countLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview()
            $0.height.equalTo(UIConstants.CountLabel.height)
            $0.width.equalTo(UIConstants.CountLabel.width)
        }
        titleView.snp.makeConstraints {
            $0.top.equalTo(countLabel.snp.bottom).offset(UIConstants.TitleView.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.TitleView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.TitleView.rightOffset)
            $0.height.equalTo(UIConstants.TitleView.height)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(UIConstants.LineView.topOffset)
            $0.left.right.equalTo(titleView)
            $0.height.equalTo(UIConstants.LineView.height)
        }
        expandView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(UIConstants.ExpandView.topOffset)
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(UIConstants.ExpandView.bottomOffset)
        }
    }
    
    func configureExpandView() {
        expandView.directionView.configure(
            image: Asset.Images.navigationIcon.image.withTintColor(.white, renderingMode: .alwaysTemplate),
            message: "길 찾기"
        )
    }
    
    func updateFavoriteUI(favorites: [String]) {
        guard let visitStation else {
            return
        }
        
        let isFavoriteStation = favorites.contains(visitStation.stationID)
        let image = isFavoriteStation ? Asset.Images.favoriteOnIcon.image : Asset.Images.favoriteOffIcon.image
        
        expandView.favoriteButton.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
        expandView.favoriteButton.imageView?.tintColor = isFavoriteStation ? .white : Asset.Colors.mainColor.color
        expandView.favoriteButton.backgroundColor = isFavoriteStation ? Asset.Colors.mainColor.color : .white
    }
}
