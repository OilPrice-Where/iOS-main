//
//  Converter.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit


// App 기본 설정
struct Preferences {
    //TODO: Check
    static func notConnect() {
        // Alert 설정
//        let appearance = SCLAlertView.SCLAppearance(
//            kWindowWidth: 300, // Alert Width
//            kTitleFont: UIFont(name: "NanumSquareRoundB", size: 18)!, // Alert Title Font
//            kTextFont: UIFont(name: "NanumSquareRoundR", size: 15)!, // Alert Content Font
//            showCloseButton: true // CloseButton isHidden = True
//        )
//        
//        let alert = SCLAlertView(appearance: appearance)
//        alert.showError("네트워크 오류 발생", subTitle: "인터넷 연결이 오프라인 상태입니다.", closeButtonTitle: "확인", colorStyle: 0x5E82FF)
//        alert.iconTintColor = UIColor.white
    }
    
    /// Kakao API Key
    static func kakaoAppKey() -> String {
        guard let appKey: String = loadPlistValue(type: .kakao) else {
            return ""
        }
        return appKey
    }
    
    /// TMap API Key
    static func tMapAppKey() -> String {
        guard let appKey: String = loadPlistValue(type: .tMap) else {
            return ""
        }
        return appKey
    }
    
    /// Random App Key
    static func stationAppKey() -> String {
        guard let appKeys: [String] = loadPlistValue(type: .oil),
              let appKey = appKeys.randomElement() else {
            return ""
        }
        return appKey
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


private extension Preferences {
    enum AppSettings: String {
        case kakao = "KakaoAPIKey"
        case tMap = "TMapAPIKey"
        case oil = "StationAppKeys"
        
        enum Path {
            static let fileName: String = "AppSettings"
            static let type: String = "plist"
        }
    }
    
    static func loadPlistValue<T>(type: AppSettings) -> T? {
        guard let plistPath = Bundle.main.path(forResource: AppSettings.Path.fileName, ofType: AppSettings.Path.type) else {
            LogUtil.e("Plist 파일을 찾을 수 없습니다.")
            return nil
        }
        
        let plistURL = URL(fileURLWithPath: plistPath)
        
        do {
            let plistData = try Data(contentsOf: plistURL)
            let dictionary = try PropertyListSerialization.propertyList(
                from: plistData,
                options: [],
                format: nil
            ) as? [String: Any]
            
            guard let dictionary,
                  let value = dictionary[type.rawValue] as? T else {
                LogUtil.e("Plist 데이터를 찾을 수 없습니다.")
                return nil
            }
            return value
        } catch {
            LogUtil.e("Plist 로드 중 에러 발생: \(error.localizedDescription)")
            return nil
        }
    }
}
