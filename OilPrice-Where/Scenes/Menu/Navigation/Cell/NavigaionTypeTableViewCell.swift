//
//  NavigaionTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import NSObject_Rx
//MARK: 찾는 내비게이션 타입 Cell
class NavigaionTypeTableViewCell: UITableViewCell {
    // Properties
    private let naviTypeLabel = UILabel().then { // 내비게이션 title
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Overide Method
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
    // Configure
    func fetch(navigation name: String) {
        // Navigation title
        naviTypeLabel.text = name
    }
    
    // Set UI
    private func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(naviTypeLabel)
        
        naviTypeLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
