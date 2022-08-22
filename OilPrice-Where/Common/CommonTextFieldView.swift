//
//  CommonTextFieldView.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Then
import SnapKit
import UIKit
import Combine
//MARK: CommonTextFieldView
final class CommonTextFieldView: UIView {
    //MARK: - Properties
    var bag = Set<AnyCancellable>()
    private var placeholder: String?
    let titleLabel = UILabel().then {
        $0.textColor = .systemGray3
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
    }
    let contentTextField = UITextField().then {
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
        $0.smartDashesType = .no
        $0.smartQuotesType = .no
        $0.spellCheckingType = .no
        $0.autocorrectionType = .no
        $0.smartInsertDeleteType = .no
        $0.returnKeyType = .search
        $0.setContentHuggingPriority(.defaultLow, for: .horizontal)
    }
    lazy var contentTextView = UITextView().then {
        $0.delegate = self
        $0.textColor = .systemGray3
        $0.font = FontFamily.NanumSquareRound.regular.font(size: 16)
    }
    
    //MARK: - Initializer
    init(isTitleHidden: Bool = false,                 // 타이틀 명
         isTextView: Bool = false,                    // TextView 표시 여부(기본: TextField)
         placeholder: String? = nil,                  // placeholder
         titleWidth: CGFloat = .zero,                 // 타이틀 크기 지정
         contentTrailing: CGFloat = 16.0) {           // text 입력 내용 표시 위치
        super.init(frame: .zero)
        
        self.placeholder = placeholder
        
        makeUI(isTitleHidden: isTitleHidden,
               isTextView: isTextView,
               titleWidth: titleWidth,
               contentTrailing: contentTrailing)
        bind()
    }
    
    required init?(coder: NSCoder) {
        fatalError("Not Created View")
    }
    
    //MARK: - Make UI
    private func makeUI(isTitleHidden: Bool,
                        isTextView: Bool,
                        titleWidth: CGFloat,
                        contentTrailing: CGFloat) {
        layer.borderWidth = 1.0
        layer.cornerRadius = 8.0
        layer.masksToBounds = true
        layer.borderColor = UIColor.systemGray3.cgColor
        
        let attrString = NSAttributedString(string: placeholder ?? "",
                                            attributes: [.foregroundColor: UIColor.systemGray3,
                                                         .font: FontFamily.NanumSquareRound.regular.font(size: 16)])
        
        addSubview(titleLabel)
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().offset(isTitleHidden ? 0 : 16)
            $0.width.equalTo(titleWidth)
        }
        
        if isTextView {
            addSubview(contentTextView)
            contentTextView.text = placeholder
            
            contentTextView.snp.makeConstraints {
                $0.left.top.right.equalToSuperview().inset(16)
                $0.bottom.equalToSuperview()
            }
        } else {
            addSubview(contentTextField)
            contentTextField.attributedPlaceholder = attrString
            
            contentTextField.snp.makeConstraints {
                $0.left.equalTo(titleLabel.snp.right).offset(16)
                $0.right.equalToSuperview().offset(-contentTrailing)
                $0.top.bottom.equalToSuperview()
            }
        }
    }
    
    private func bind() {
        contentTextField
            .controlEventPublisher(for: .editingDidEnd)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.layer.borderColor = UIColor.systemGray3.cgColor
            }
            .store(in: &bag)
        
        contentTextField
            .didBeginEditingPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.layer.borderColor = UIColor.black.cgColor
            }
            .store(in: &bag)
    }
}

extension CommonTextFieldView: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        layer.borderColor = UIColor.black.cgColor
        
        guard textView.text == placeholder else { return }
        
        textView.text = ""
        textView.textColor = .black
        textView.font = FontFamily.NanumSquareRound.regular.font(size: 16)
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        layer.borderColor = UIColor.systemGray3.cgColor
        
        guard textView.text.isEmpty else { return }
        
        textView.text = placeholder
        textView.textColor = .systemGray3
        textView.font = FontFamily.NanumSquareRound.regular.font(size: 16)
    }
}
