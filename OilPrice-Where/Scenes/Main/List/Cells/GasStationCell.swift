//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit


protocol GasStationCellDelegate: AnyObject {
    /// 즐겨찾기 설정 및 해제
    func touchedFavoriteButton(stationID: String)
    func touchedDirectionButton(station summary: GasStationSummary)
}


extension GasStationCell {
    func configure(station summary: GasStationSummary) {
        self.summary = summary
        
        let ids = DefaultData.shared.favoriteSubject.value
        let isFavoriteStation = ids.contains(summary.stationID)
        stationView.configure(with: summary, isFavoriteStation: isFavoriteStation)
    }
}


//MARK: 메인페이지의 리스트 부분에서 받아오는 주유소 목록을 나타내는 셀
final class GasStationCell: UICollectionViewCell {
    //MARK: - Properties
    weak var delegate: GasStationCellDelegate?
    
    private var cancellable = Set<AnyCancellable>()
    private var summary: GasStationSummary?
    
    private let stationView = GasStationView()
    
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - BindActions
private extension GasStationCell {
    func bindActions() {
        stationView.favoriteButton
            .tapPublisher
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] in
                guard let self,
                      let summary,
                      summary.stationID.isNotEmpty else {
                    return
                }
                delegate?.touchedFavoriteButton(stationID: summary.stationID)
            }
            .store(in: &cancellable)
        
        stationView.directionView
            .gesturePublisher()
            .throttle(for: 0.5, scheduler: DispatchQueue.main, latest: false)
            .sink { [weak self] _ in
                guard let self,
                      let summary else {
                    return
                }
                delegate?.touchedDirectionButton(station: summary)
            }
            .store(in: &cancellable)
    }
}


//MARK: - Set UI
private extension GasStationCell {
    enum UIConstants {
        enum FavoriteButton {
            static let image: UIImage = Asset.Images.favoriteOffIcon.image.withRenderingMode(.alwaysTemplate)
            static let tintColor: UIColor = Asset.Colors.mainColor.color
            static let borderWidth: CGFloat = 1.0
            static let borderColor: CGColor = Asset.Colors.mainColor.color.cgColor
            static let cornerRadius: CGFloat = 5
            
            static let leftOffset: CGFloat = 16
            static let width: CGFloat = 80
        }
        
        enum StationView {
            static let cornerRadius: CGFloat = 5
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        backgroundColor = .systemGroupedBackground
        stationView.layer.cornerRadius = UIConstants.StationView.cornerRadius
        
        contentView.addSubview(stationView)
    }
    
    func setConstraints() {
        stationView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
