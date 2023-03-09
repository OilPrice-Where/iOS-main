//
//  LodingView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import SnapKit
import Then
//MARK: 즐겨찾기 로딩 뷰
final class LodingView: UIView {
    // Properties
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .medium)
    
    // Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set UI
    private func makeUI() {
        addSubview(activityIndicator)
        
        activityIndicator.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.centerX.equalToSuperview()
        }
    }
}
