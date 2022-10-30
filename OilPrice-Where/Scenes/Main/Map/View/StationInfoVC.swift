//
//  StationInfoVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa
import Toast
//MARK: MapView에 주유소 정보 VC
final class StationInfoVC: CommonViewController {
    //MARK: - Properties
    var stationInfoView = StationInfoView()
    var station: InformationGasStaion? = nil { didSet { configure(_station: station) } }
    var guideView = UIView().then {
        $0.backgroundColor = .systemGray4
        $0.layer.cornerRadius = 1.3
    }
    var topLineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    var titleByStationDetailLabel = UILabel().then {
        $0.text = "주유소 상세정보"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    var washImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconWash.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    var repairImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconRepair.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    var convenienceImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        let image = Asset.Images.iconConvenience.image.withRenderingMode(.alwaysTemplate)
        $0.image = image
        $0.tintColor = .lightGray
    }
    var addressKeyLabel = UILabel().then {
        $0.text = "주소"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var phoneNumberKeyLabel = UILabel().then {
        $0.text = "전화"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .lightGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    lazy var addressValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 14)
        $0.addTarget(self, action: #selector(fetchAddressCopy), for: .touchUpInside)
    }
    lazy var phoneNumberValueButton = UIButton().then {
        $0.contentHorizontalAlignment = .right
        $0.titleLabel?.font = FontFamily.NanumSquareRound.bold.font(size: 14)
        $0.addTarget(self, action: #selector(fetchTel), for: .touchUpInside)
    }
    var bottomLineView = UIView().then {
        $0.backgroundColor = .systemGroupedBackground
    }
    var titleByPriceLabel = UILabel().then {
        $0.text = "가격 정보"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    var oilKeyLabel = UILabel().then {
        $0.text = "휘발유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var highOilKeyLabel = UILabel().then {
        $0.text = "고급유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var diselKeyLabel = UILabel().then {
        $0.text = "경유"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var lpgKeyLabel = UILabel().then {
        $0.text = "LPG"
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        $0.textColor = .darkGray
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
    }
    var oilValueLabel = UILabel().then {
        $0.text = "가격정보 없음"
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 14)
    }
    var highOilValueLabel = UILabel().then {
        $0.text = "가격정보 없음"
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 14)
    }
    var diselValueLabel = UILabel().then {
        $0.text = "가격정보 없음"
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 14)
    }
    var lpgValueLabel = UILabel().then {
        $0.text = "가격정보 없음"
        $0.textAlignment = .right
        $0.font = FontFamily.NanumSquareRound.extraBold.font(size: 14)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    //MARK: - Set UI
    private func makeUI() {
        view.backgroundColor = .white
        view.addSubview(stationInfoView)
        view.addSubview(guideView)
        view.addSubview(topLineView)
        view.addSubview(titleByStationDetailLabel)
        view.addSubview(washImageView)
        view.addSubview(repairImageView)
        view.addSubview(convenienceImageView)
        view.addSubview(addressKeyLabel)
        view.addSubview(phoneNumberKeyLabel)
        view.addSubview(addressValueButton)
        view.addSubview(phoneNumberValueButton)
        view.addSubview(bottomLineView)
        view.addSubview(titleByPriceLabel)
        view.addSubview(oilKeyLabel)
        view.addSubview(highOilKeyLabel)
        view.addSubview(diselKeyLabel)
        view.addSubview(lpgKeyLabel)
        view.addSubview(oilValueLabel)
        view.addSubview(highOilValueLabel)
        view.addSubview(diselValueLabel)
        view.addSubview(lpgValueLabel)
        
        guideView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(30)
            $0.height.equalTo(2.6)
        }
        
        stationInfoView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview().offset(10)
            $0.height.equalTo(88)
        }
        topLineView.snp.makeConstraints {
            $0.top.equalTo(stationInfoView.snp.bottom).offset(10)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(5)
        }
        titleByStationDetailLabel.snp.makeConstraints {
            $0.top.equalTo(topLineView.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview()
        }
        convenienceImageView.snp.makeConstraints {
            $0.right.equalToSuperview().offset(-16)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(20)
        }
        repairImageView.snp.makeConstraints {
            $0.right.equalTo(convenienceImageView.snp.left).offset(-4)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(20)
        }
        washImageView.snp.makeConstraints {
            $0.right.equalTo(repairImageView.snp.left).offset(-4)
            $0.centerY.equalTo(titleByStationDetailLabel.snp.centerY)
            $0.size.equalTo(20)
        }
        addressKeyLabel.snp.makeConstraints {
            $0.top.equalTo(titleByStationDetailLabel.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(14)
        }
        phoneNumberKeyLabel.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        addressValueButton.snp.makeConstraints {
            $0.top.equalTo(addressKeyLabel.snp.top)
            $0.left.equalTo(addressKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        phoneNumberValueButton.snp.makeConstraints {
            $0.top.equalTo(phoneNumberKeyLabel.snp.top)
            $0.left.equalTo(phoneNumberKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        bottomLineView.snp.makeConstraints {
            $0.top.equalTo(phoneNumberValueButton.snp.bottom).offset(10)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(5)
        }
        titleByPriceLabel.snp.makeConstraints {
            $0.top.equalTo(bottomLineView.snp.bottom).offset(16)
            $0.left.equalToSuperview().offset(14)
            $0.right.equalToSuperview()
        }
        oilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(titleByPriceLabel.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(14)
        }
        highOilKeyLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        diselKeyLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        lpgKeyLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.bottom).offset(8)
            $0.left.equalToSuperview().offset(14)
        }
        oilValueLabel.snp.makeConstraints {
            $0.top.equalTo(oilKeyLabel.snp.top)
            $0.left.equalTo(oilKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        highOilValueLabel.snp.makeConstraints {
            $0.top.equalTo(highOilKeyLabel.snp.top)
            $0.left.equalTo(highOilKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        diselValueLabel.snp.makeConstraints {
            $0.top.equalTo(diselKeyLabel.snp.top)
            $0.left.equalTo(diselKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
        lpgValueLabel.snp.makeConstraints {
            $0.top.equalTo(lpgKeyLabel.snp.top)
            $0.left.equalTo(lpgKeyLabel.snp.left).offset(5)
            $0.right.equalToSuperview().offset(-14)
        }
    }
    
    //MARK: - Configure station
    func configure(_station: InformationGasStaion?) {
        guard let info = _station else { return }
        
        washImageView.tintColor = info.carWash == "Y" ? Asset.Colors.mainColor.color : .lightGray
        repairImageView.tintColor = info.repairShop == "Y" ? Asset.Colors.mainColor.color : .lightGray
        convenienceImageView.tintColor = info.convenienceStore == "Y" ? Asset.Colors.mainColor.color : .lightGray
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.styleThick.rawValue]
        var underlineAttributedString = NSAttributedString(string: info.address ?? "", attributes: underlineAttribute)
        addressValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
        addressValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
        
        underlineAttributedString = NSAttributedString(string: info.phoneNumber ?? "", attributes: underlineAttribute)
        phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .normal)
        phoneNumberValueButton.setAttributedTitle(underlineAttributedString, for: .highlighted)
        
        oilValueLabel.text = string(info, to: "B027")
        highOilValueLabel.text = string(info, to: "B034")
        diselValueLabel.text = string(info, to: "D047")
        lpgValueLabel.text = string(info, to: "K015")
    }
    
    func string(_ info: InformationGasStaion, to code: String) -> String {
        let price = Preferences.priceToWon(price: info.price?.first(where: { $0.type == code })?.price ?? 0)
        return price == "0" ? "가격 정보 없음" : price
    }
    
    @objc
    func fetchAddressCopy() {
        guard let valueString = addressValueButton.titleLabel?.text else { return }
        UIPasteboard.general.string = valueString
        
        guard let vc = UIApplication.shared.customKeyWindow?.visibleViewController as? UIViewController else { return }
        let lbl = Preferences.showToast(message: "주유소 주소가 복사되었습니다.")
        
        vc.view.hideToast()
        vc.view.showToast(lbl, position: .top)
    }
    
    @objc
    func fetchTel() {
        guard let valueString = phoneNumberValueButton.titleLabel?.text,
              let url = URL(string: "tel:" + valueString),
              UIApplication.shared.canOpenURL(url) else { return }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
}
