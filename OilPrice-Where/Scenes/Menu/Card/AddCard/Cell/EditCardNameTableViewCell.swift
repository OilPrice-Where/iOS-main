//
//  CardNameTableViewCell.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/08/14.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Then
import SnapKit

class EditCardNameTableViewCell: UITableViewCell {
    // Properties
    private let nameLabel = UILabel().then {
        $0.text = "카드 별칭"
        $0.font = FontFamily.NanumSquareRound.bold.font(size: 16)
    }
    private lazy var nameTextField = UITextField().then {
        $0.delegate = self
        $0.placeholder = "카드의 이름을 작성해주세요."
        $0.clearButtonMode = .whileEditing
    }
    private let textFieldUnderLineview = UIView().then {
        $0.backgroundColor = .systemGray
    }
    
    // Initializer
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func makeUI() {        
        contentView.addSubview(nameLabel)
        contentView.addSubview(nameTextField)
        contentView.addSubview(textFieldUnderLineview)
        
        nameLabel.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
        }
        nameTextField.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(12)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }
        textFieldUnderLineview.snp.makeConstraints {
            $0.top.equalTo(nameTextField.snp.bottom).offset(8)
            $0.left.right.equalTo(nameTextField)
            $0.height.equalTo(1)
        }
        
    }
}

extension EditCardNameTableViewCell: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard textField.text?.count ?? 0 < 6 else { return false }
        
        return true
    }
}
