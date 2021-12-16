//
//  FindDistanceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 10..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

// 설정 -> 탐색 반경 선택 리스트 셀
class FindDistanceTableViewCell: UITableViewCell {
    //MARK: - Properties
    // 탐색 반경 레이블
    let distanceLabel = UILabel().then {
        $0.textAlignment = .left
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 17)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        accessoryType = selected ? .checkmark : .none
    }
    
    //MARK: - Fetch Data
    func fetch(distance: String) {
        distanceLabel.text = distance // 탐색 반경 리스트(1,3,5KM)를 셀에 표시
    }
    
    func configureUI() {
        selectionStyle = .none
        
        contentView.addSubview(distanceLabel)
        
        distanceLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
