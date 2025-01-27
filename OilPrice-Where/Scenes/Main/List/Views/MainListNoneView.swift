//
//  MainListNoneView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: List가 없을 때 표시하는 View
final class MainListNoneView: UIView {
    //MARK: - Properties
    private let noneListImageView = UIImageView().then {
        $0.image = Asset.Images.noneListImage.image
        $0.contentMode = .scaleAspectFit
    }
    private let noneListLabel = UILabel().then {
        $0.text = UIConstants.NoneListLabel.text
        $0.textAlignment = .center
        $0.textColor = .darkGray
        $0.font = UIConstants.NoneListLabel.font
    }
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Set UI
private extension MainListNoneView {
    enum UIConstants {
        enum NoneListImageView {
            static let centerYMutiple: CGFloat = 0.75
            static let width: CGFloat = 140
            static let height: CGFloat = 130
            
        }
        
        enum NoneListLabel {
            static let text: String = "근처 주유소를 찾을 수 없습니다"
            static let font: UIFont = FontFamily.NanumSquareRound.regular.font(size: 17)
            
            static let topOffset: CGFloat = 15
            static let height: CGFloat = 20
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(noneListImageView)
        addSubview(noneListLabel)
    }
    
    func setConstraints() {
        noneListImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().multipliedBy(UIConstants.NoneListImageView.centerYMutiple)
            $0.width.equalTo(UIConstants.NoneListImageView.width)
            $0.height.equalTo(UIConstants.NoneListImageView.height)
        }
        noneListLabel.snp.makeConstraints {
            $0.top.equalTo(noneListImageView.snp.bottom).offset(UIConstants.NoneListLabel.topOffset)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(UIConstants.NoneListLabel.height)
        }
    }
}
