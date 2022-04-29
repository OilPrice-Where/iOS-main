//
//  PlusView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/29.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
//MARK: PlusView
final class PlusView: UIView {
    //MARK: - Properties
    let hView = UIView().then {
        $0.layer.cornerRadius = 0.5
        $0.backgroundColor = Asset.Colors.mainColor.color
    }
    let vView = UIView().then {
        $0.layer.cornerRadius = 0.5
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
    
    //MARK: - Make UI
    func makeUI() {
        addSubview(hView)
        addSubview(vView)
        
        hView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.height.equalTo(1.5)
        }
        
        vView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(1.5)
        }
    }
}
