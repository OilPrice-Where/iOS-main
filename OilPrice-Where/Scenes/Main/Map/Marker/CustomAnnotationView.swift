//
//  CustomAnnotationView.swift
//  OilPrice-Where
//
//  Created by wargi on 2/8/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit
import Then


extension CustomAnnotationView {
    func configure(isSelectedMarker isSelected: Bool) {
        if isSelected {
            mapMarkerImageView.image = UIConstants.MapMarkerImageView.markerImage(type: .selected)
            priceLabel.textColor = .white
        } else {
            mapMarkerImageView.image = UIConstants.MapMarkerImageView.markerImage(type: type)
            priceLabel.textColor = type == .none ? .black : .white
        }
    }
}


//MARK: 지도에서 실질적으로 표시 되는 뷰
final class CustomAnnotationView: UIView {
    // MARK: - Properties
    private var type: MarkerType
    /// 마커 내부의 주유소 정보
    private let station: GasStationSummary
    
    private let mapMarkerImageView = UIImageView().then {
        $0.image = UIConstants.MapMarkerImageView.markerImage(type: .none)
        $0.frame = UIConstants.MapMarkerImageView.frmae
        $0.layer.masksToBounds = true
    }
    private let logoImageView = UIImageView().then {
        $0.frame = UIConstants.LogoImageView.frmae
    }
    private let priceLabel = UILabel().then {
        $0.frame = UIConstants.PriceLabel.frmae
        $0.textAlignment = .left
        $0.font = UIConstants.PriceLabel.font
    }

    
    //MARK: - Initializer
    init(markerType type: MarkerType,
         station: GasStationSummary) {
        self.type = type
        self.station = station
        
        super.init(frame: UIConstants.ContentView.frmae)
        
        makeUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


extension CustomAnnotationView {
    enum MarkerType {
        case selected
        case low
        case none
    }
    
    func asImage() -> UIImage {
        let render = UIGraphicsImageRenderer(bounds: bounds)
        return render.image { context in
            layer.render(in: context.cgContext)
        }
    }
}


//MARK: - Set UI
private extension CustomAnnotationView {
    enum UIConstants {
        enum ContentView {
            static let frmae: CGRect = .init(x: 0, y: 0, width: 60, height: 32)
        }
        
        enum MapMarkerImageView {
            static let frmae: CGRect = .init(x: 0, y: 0, width: 60, height: 32)
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 12)
            
            static func markerImage(type: MarkerType) -> UIImage {
                switch type {
                case .selected:
                    return Asset.Images.selectMapMarker.image
                case .low:
                    return Asset.Images.minMapMarker.image
                case .none:
                    return Asset.Images.nonMapMarker.image
                }
            }
        }
        
        enum LogoImageView {
            static let frmae: CGRect = .init(x: 5, y: 5, width: 15, height: 15)
        }
        
        enum PriceLabel {
            static let frmae: CGRect = .init(x: 20, y: 4, width: 37, height: 18)
            static let font: UIFont = FontFamily.NanumSquareRound.extraBold.font(size: 13)
        }
    }
    
    func makeUI() {
        configureUI()
        updateUI()
    }
    
    func configureUI() {
        addSubview(mapMarkerImageView)
        addSubview(logoImageView)
        addSubview(priceLabel)
    }
    
    func updateUI() {
        priceLabel.text = station.price.decimalNumber
        logoImageView.image = station.brand.image
    }
}

