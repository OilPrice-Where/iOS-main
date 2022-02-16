//
//  GasStationView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/15.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
//MARK: GasStationCell의 ContentView
final class GasStationView: UIView {
    //MARK: - Properties
    let titleView = GasStationTitleView()
    let bottomView = GasStationBottomView()
    let lineView = UIView().then {
        $0.backgroundColor = UIColor(red: 236/255, green: 236/255, blue: 236/255, alpha: 1.0)
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
        backgroundColor = .white
        
        addSubview(titleView)
        addSubview(lineView)
        addSubview(bottomView)
        
        titleView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(12)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(30)
        }
        lineView.snp.makeConstraints {
            $0.top.equalTo(titleView.snp.bottom).offset(8)
            $0.left.right.equalTo(titleView)
            $0.height.equalTo(1.2)
        }
        bottomView.snp.makeConstraints {
            $0.top.equalTo(lineView.snp.bottom).offset(8)
            $0.left.bottom.right.equalToSuperview()
        }
    }
}
