//
//  Converter.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation

// 카텍 좌표 저장
struct KatecPoint {
    let x: Double
    let y: Double
}

// App 기본 설정
struct Preferences {
    static func notConnect() {
        // Alert 설정
        let appearance = SCLAlertView.SCLAppearance(
            kWindowWidth: 300, // Alert Width
            kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!, // Alert Title Font
            kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!, // Alert Content Font
            showCloseButton: true // CloseButton isHidden = True
        )
        
        let alert = SCLAlertView(appearance: appearance)
        alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
        alert.iconTintColor = UIColor.white
    }
    
    // Random App Key
    // 5개의 App Key중 랜덤하게 한 개의 App Key 반환
    static func getAppKey() -> String {
        var appKey = ""
        
        switch Int.random(in: 0 ... 5) {
        case 0:
            appKey = "F302180619"
        case 1:
            appKey = "F303180619"
        case 2:
            appKey = "F304180619"
        case 3:
            appKey = "F305180619"
        case 4:
            appKey = "F306180619"
        default:
            appKey = "F307180619"
        }
        
        return appKey
    }
    
    static func stringByRemovingControlCharacters2(string: String) -> String {
        let controlChars = NSCharacterSet.controlCharacters
        var range = string.rangeOfCharacter(from: controlChars)
        var mutable = string
        while let removeRange = range {
            mutable.removeSubrange(removeRange)
            range = mutable.rangeOfCharacter(from: controlChars)
        }
        return mutable
    }
    
    static func showToast(width: CGFloat, message : String, subTitle: String = "") -> UILabel {
        let rect = CGRect(x: UIScreen.main.bounds.width - (width / 2),
                          y: 100,
                          width: width,
                          height: 54)
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6
        let attrString = NSMutableAttributedString(string: message)
        attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
        
        let toastLabel = UILabel(frame: rect)
        toastLabel.font = FontFamily.NanumSquareRound.extraBold.font(size: 11)
        toastLabel.attributedText = attrString.apply(word: subTitle, attrs: [.font: FontFamily.NanumSquareRound.regular.font(size: 11)])
        toastLabel.backgroundColor = .black.withAlphaComponent(0.75)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5.0
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = 2
        
        return toastLabel
    }
    
    static func showToast(width: CGFloat = 200, message : String, numberOfLines: Int = 1) -> UILabel {
        let rect = CGRect(x: UIScreen.main.bounds.width - (width / 2),
                          y: 100,
                          width: width,
                          height: 35)
        
        let toastLabel = UILabel(frame: rect)
        toastLabel.font = FontFamily.NanumSquareRound.regular.font(size: 14)
        toastLabel.text = message
        toastLabel.backgroundColor = .black.withAlphaComponent(0.75)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5.0
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = numberOfLines
        
        return toastLabel
    }
}
