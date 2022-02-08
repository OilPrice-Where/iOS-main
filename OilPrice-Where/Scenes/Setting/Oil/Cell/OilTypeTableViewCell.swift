//
//  OilTypeTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 9..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 설정 -> 오일 타입 선택 리스트 셀
final class OilTypeTableViewCell: UITableViewCell {
    //MARK: - Properties
    // 오일 종류
    let oilTypeLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    //MARK: - Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
    //MARK: - Fetch Data
    func fetch(oil type: String) {
        oilTypeLabel.text = type // 오일의 종류(휘발유, 경유, LPG 등..)를 셀에 표시
    }
    
    //MARK: - Configure UI
    func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(oilTypeLabel)
        
        oilTypeLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
