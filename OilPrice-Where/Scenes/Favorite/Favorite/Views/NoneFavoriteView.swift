//
//  NoneFavoriteView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit


//MARK: 즐겨찾기가 없을 때 표시하는 뷰
final class NoneFavoriteView: UIView {
    //MARK: Properties
    private let emptyImageView = UIImageView().then {
        $0.image = UIConstants.EmptyImageView.image
        $0.contentMode = .scaleAspectFit
    }
    private let emptyLabel = UILabel().then {
        $0.text = UIConstants.EmptyLabel.text
        $0.textColor = .white
        $0.textAlignment = .center
        $0.font = UIConstants.EmptyLabel.font
    }
    
    
    //MARK: Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//MARK: - Set UI
private extension NoneFavoriteView {
    enum UIConstants {
        enum EmptyImageView {
            static let image: UIImage = Asset.Images.nonePageImage.image
        }
        
        enum EmptyLabel {
            static let text: String = "즐겨 찾는 주유소가 없습니다."
            static let font: UIFont = FontFamily.NanumSquareRound.bold.font(size: 20)
            
            static let topOffset: CGFloat = 12
            static let height: CGFloat = 23
        }
    }
    
    func makeUI() {
        configureUI()
        setConstraints()
    }
    
    func configureUI() {
        addSubview(emptyImageView)
        addSubview(emptyLabel)
    }
    
    func setConstraints() {
        emptyImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        emptyLabel.snp.makeConstraints {
            $0.top.equalTo(emptyImageView.snp.bottom).offset(UIConstants.EmptyLabel.topOffset)
            $0.left.right.equalToSuperview()
            $0.height.equalTo(UIConstants.EmptyLabel.height)
        }
    }
}
