//
//  FindDistanceTableViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 10..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

//MARK: 탐색 반경 선택 셀
final class FindDistanceTableViewCell: UITableViewCell {
    // Properties
    private let distanceLabel = UILabel().then { // 탐색 반경 레이블
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
    func fetch(distance: String) {
        distanceLabel.text = distance // 탐색 반경 리스트(1,3,5KM)를 셀에 표시
    }
    
    // Set UI
    private func makeUI() {
        selectionStyle = .none
        
        contentView.addSubview(distanceLabel)
        
        distanceLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }
}
