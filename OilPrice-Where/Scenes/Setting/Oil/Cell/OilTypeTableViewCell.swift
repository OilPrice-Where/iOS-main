//
//  OilTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
//MARK: 찾는 유종 Cell
final class OilTypeTableViewCell: UITableViewCell {
    // Properties
    private let oilTypeLabel = UILabel().then { // 오일 종류
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
    
    // Override Method
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
    // Configure Data
    func fetch(oil type: String) {
        oilTypeLabel.text = type // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
    }
    
    // Set UI
    private func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(oilTypeLabel)
        
        oilTypeLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
