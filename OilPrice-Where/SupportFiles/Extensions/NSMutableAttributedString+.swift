//
//  NSMutableAttributedString.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/20.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    func apply(word: String, attrs: [NSAttributedString.Key: Any]) -> NSMutableAttributedString {
        let range = (self.string as NSString).range(of: word)
        return apply(word: word, attrs: attrs, range: range, last: range)
    }
    
    private func apply(word: String, attrs: [NSAttributedString.Key: Any], range: NSRange, last: NSRange) -> NSMutableAttributedString {
        if range.location != NSNotFound {
            self.addAttributes(attrs, range: range)
            let start = last.location + last.length
            let end = self.string.count - start
            let stringRange = NSRange(location: start, length: end)
            let newRange = (self.string as NSString).range(of: word, options: [], range: stringRange)
            _ = apply(word: word, attrs: attrs, range: newRange, last: range)
        }
        return self
    }
}

// MARK: - 크기 계산
extension NSAttributedString {
    func height(withConstrainedWidth width: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.height)
    }

    func width(withConstrainedHeight height: CGFloat) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, context: nil)
    
        return ceil(boundingBox.width)
    }
}
