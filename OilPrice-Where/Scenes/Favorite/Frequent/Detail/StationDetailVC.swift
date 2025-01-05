//
//  StationDetailVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/28.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import Then
import SnapKit
import NMapsMap


final class StationDetailVC: CommonViewController {
    //MARK: - Properties
    private let viewModel: StationDetailViewModel
    
    private let mapView = NMFMapView().then {
        $0.mapType = .navi
        $0.positionMode = .direction
        $0.minZoomLevel = UIConstants.MapView.minZoomLevel
        $0.maxZoomLevel = UIConstants.MapView.maxZoomLevel
        $0.extent = UIConstants.MapView.extent
        $0.layer.cornerRadius = UIConstants.MapView.cornerRadius
        $0.allowsScrolling = false
    }
    private let navigationTitleView = CustomNavigationTitleView()
    private let washImageView = UIImageView().then {
        $0.image = UIConstants.WashImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let repairImageView = UIImageView().then {
        $0.image = UIConstants.RepairImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let convenienceImageView = UIImageView().then {
        $0.image = UIConstants.ConvenienceImageView.image
        $0.tintColor = .lightGray
        $0.contentMode = .scaleAspectFit
    }
    private let priceInfoLabel = UILabel().then {
        $0.text = UIConstants.PriceInfoLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.PriceInfoLabel.font
    }
    private let oilKeyLabel = UILabel().then {
        $0.text = UIConstants.OilKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.OilKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let highOilKeyLabel = UILabel().then {
        $0.text = UIConstants.HighOilKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.HighOilKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let diselKeyLabel = UILabel().then {
        $0.text = UIConstants.DiselKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.DiselKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let lpgKeyLabel = UILabel().then {
        $0.text = UIConstants.LpgKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.LpgKeyLabel.font
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let oilValueLabel = UILabel().then {
        $0.text = UIConstants.OilValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.OilValueLabel.font
    }
    private let highOilValueLabel = UILabel().then {
        $0.text = UIConstants.HighOilValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.HighOilValueLabel.font
    }
    private let diselValueLabel = UILabel().then {
        $0.text = UIConstants.DiselValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.DiselValueLabel.font
    }
    private let lpgValueLabel = UILabel().then {
        $0.text = UIConstants.LpgValueLabel.text
        $0.textAlignment = .right
        $0.font = UIConstants.LpgValueLabel.font
    }
    private let bottomLine = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    private let detailInfoLabel = UILabel().then {
        $0.text = UIConstants.DetailInfoLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.DetailInfoLabel.font
    }
    private let addressKeyLabel = UILabel().then {
        $0.text = UIConstants.AddressKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.AddressKeyLabel.font
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let phoneNumberKeyLabel = UILabel().then {
        $0.text = UIConstants.PhoneNumberKeyLabel.text
        $0.textAlignment = .left
        $0.font = UIConstants.PhoneNumberKeyLabel.font
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    private let addressValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = UIConstants.AddressValueButton.font
    }
    private let phoneNumberValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = UIConstants.PhoneNumberValueButton.font
    }
    private let expandView = GasStationExpandView(height: UIConstants.ExpandView.height).then {
        $0.directionView.configure(msg: UIConstants.ExpandView.title)
    }
    
    //MARK: - Life Cycle
    init(viewModel: StationDetailViewModel) {
        self.viewModel = viewModel
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        navigationItem.titleView = naviTitleView
        view.backgroundColor = .white
        
        let backItem = UIBarButtonItem()
        navigationController?.navigationBar.topItem?.backBarButtonItem = backItem
        
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        view.addSubview(navigationTitleView)
        view.addSubview(washImageView)
        view.addSubview(repairImageView)
        view.addSubview(convenienceImageView)
        view.addSubview(priceInfoLabel)
        view.addSubview(oilKeyLabel)
        view.addSubview(diselKeyLabel)
        view.addSubview(highOilKeyLabel)
        view.addSubview(lpgKeyLabel)
        view.addSubview(oilValueLabel)
        view.addSubview(diselValueLabel)
        view.addSubview(highOilValueLabel)
        view.addSubview(lpgValueLabel)
        view.addSubview(bottomLine)
        view.addSubview(detailInfoLabel)
        view.addSubview(addressKeyLabel)
        view.addSubview(phoneNumberKeyLabel)
        view.addSubview(addressValueButton)
        view.addSubview(phoneNumberValueButton)
        view.addSubview(expandView)
        view.addSubview(mapView)
    }
    
    func setConstraints() {
        washImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(repairImageView.snp.left).offset(UIConstants.WashImageView.rightOffset)
            $0.size.equalTo(UIConstants.WashImageView.size)
        }
        repairImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalTo(convenienceImageView.snp.left).offset(UIConstants.RepairImageView.rightOffset)
            $0.size.equalTo(UIConstants.RepairImageView.size)
        }
        convenienceImageView.snp.makeConstraints {
            $0.centerY.equalTo(priceInfoLabel)
            $0.right.equalToSuperview().offset(UIConstants.ConvenienceImageView.rightOffset)
            $0.size.equalTo(UIConstants.ConvenienceImageView.size)
        }
        priceInfoLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.PriceInfoLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.PriceInfoLabel.leftOffset)
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(priceInfoLabel.snp.bottom).offset(UIConstants.OilKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.OilKeyLabel.leftOffset)
        }
        highOilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.bottom).offset(UIConstants.HighOilKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.HighOilKeyLabel.leftOffset)
        }
        diselKeyLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.bottom).offset(UIConstants.DiselKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.DiselKeyLabel.leftOffset)
        }
        lpgKeyLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.bottom).offset(UIConstants.LpgKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.LpgKeyLabel.leftOffset)
        }
        oilValueLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.top)
            $0.left.equalTo(oilKeyLabel.snp.left).offset(UIConstants.OilValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.OilValueLabel.rightOffset)
        }
        highOilValueLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.top)
            $0.left.equalTo(highOilKeyLabel.snp.left).offset(UIConstants.HighOilValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.HighOilValueLabel.rightOffset)
        }
        diselValueLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.top)
            $0.left.equalTo(diselKeyLabel.snp.left).offset(UIConstants.DiselValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DiselValueLabel.rightOffset)
        }
        lpgValueLabel.snp.makeConstraints {
            $0.top.equalTo(lpgKeyLabel.snp.top)
            $0.left.equalTo(lpgKeyLabel.snp.left).offset(UIConstants.LpgValueLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.LpgValueLabel.rightOffset)
        }
        bottomLine.snp.makeConstraints {
            $0.top.equalTo(lpgValueLabel.snp.bottom).offset(UIConstants.BottomLine.topOffset)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(UIConstants.BottomLine.height)
        }
        detailInfoLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLine.snp.bottom).offset(UIConstants.DetailInfoLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.DetailInfoLabel.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.DetailInfoLabel.rightOffset)
        }
        mapView.snp.makeConstraints {
            $0.top.equalTo(detailInfoLabel.snp.bottom).offset(UIConstants.MapView.topOffset)
            $0.left.equalToSuperview().inset(UIConstants.MapView.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.MapView.rightOffset)
            $0.height.equalTo(UIConstants.MapView.height)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(mapView.snp.bottom).offset(UIConstants.AddressKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.AddressKeyLabel.leftOffset)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(UIConstants.PhoneNumberKeyLabel.topOffset)
            $0.left.equalToSuperview().offset(UIConstants.PhoneNumberKeyLabel.leftOffset)
        }
        addressValueButton.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(UIConstants.AddressValueButton.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.AddressValueButton.rightOffset)
        }
        phoneNumberValueButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(UIConstants.PhoneNumberValueButton.leftOffset)
            $0.right.equalToSuperview().offset(UIConstants.PhoneNumberValueButton.rightOffset)
        }
        expandView.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(UIConstants.ExpandView.bottomOffset)
            $0.left.right.equalToSuperview()
        }
    }
}
