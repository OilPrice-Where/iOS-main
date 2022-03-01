//
//  MainListHeaderView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class MainListHeaderView: UIView {
    //MARK: - Properties
    let priceView = PriceView()
    let emptyView = UIView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        backgroundColor = Asset.Colors.mainColor.color
        
        addSubview(priceView)
        addSubview(emptyView)
        
        priceView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(162)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(priceView.snp.bottom).offset(20)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func fetchData(getCode: String?) {
        priceView.fetchAverageCosts()
    }
}
