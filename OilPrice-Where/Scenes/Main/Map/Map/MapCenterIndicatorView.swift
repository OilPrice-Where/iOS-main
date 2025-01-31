//
//  MapCenterIndicatorView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/29.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: `+` 모양으로 지도의 가운데 표시하기 위한 뷰
final class MapCenterIndicatorView: UIView {
    //MARK: - Properties
    let horizontalView = UIView().then {
        $0.layer.cornerRadius = UIConstants.HorizontalView.cornerRadius
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    let verticalView = UIView().then {
        $0.layer.cornerRadius = UIConstants.VerticalView.cornerRadius
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
}


//MARK: - Set UI
private extension MapCenterIndicatorView {
    enum UIConstants {
        enum HorizontalView {
            static let cornerRadius: CGFloat = 0.5
            static let height: CGFloat = 1.5
        }
        
        enum VerticalView {
            static let cornerRadius: CGFloat = 0.5
            static let width: CGFloat = 1.5
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(horizontalView)
        addSubview(verticalView)
    }
    
    func setConstraints() {
        horizontalView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(UIConstants.HorizontalView.height)
        }
        verticalView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(UIConstants.VerticalView.width)
        }
    }
}
