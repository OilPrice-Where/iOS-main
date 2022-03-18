//
//  ToListView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/03/02.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: ToListView
final class ToListView: UIView {
    //MARK: - Properties
    private let logoImageView = UIImageView().then {
        $0.image = Asset.Images.listButton.image
    }
    private let titleLabel = UILabel().then {
        $0.text = "목록"
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 8)
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Set UI
    private func makeUI() {
        addSubview(logoImageView)
        addSubview(titleLabel)
        
        logoImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-2.5)
        }
    }
}
