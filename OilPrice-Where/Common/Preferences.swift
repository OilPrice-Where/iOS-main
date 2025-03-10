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
    
    static func showToast(width: CGFloat = 200, message: String, subTitle: String = "", numberOfLines: Int = 1) -> UILabel {
        let hasSubTitle = !subTitle.isEmpty
        let height: CGFloat = hasSubTitle ? 54 : 35
        let font = hasSubTitle ? FontFamily.NanumSquareRound.extraBold.font(size: 11) : FontFamily.NanumSquareRound.regular.font(size: 14)
        let lines = hasSubTitle ? 2 : numberOfLines
        
        let rect = CGRect(x: UIScreen.main.bounds.width - (width / 2),
                          y: 100,
                          width: width,
                          height: height)
        
        let toastLabel = UILabel(frame: rect)
        toastLabel.font = font
        toastLabel.backgroundColor = .black.withAlphaComponent(0.75)
        toastLabel.textColor = .white
        toastLabel.textAlignment = .center
        toastLabel.alpha = 1.0
        toastLabel.layer.cornerRadius = 5.0
        toastLabel.clipsToBounds = true
        toastLabel.numberOfLines = lines
        
        if hasSubTitle {
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6
            let attrString = NSMutableAttributedString(string: message)
            attrString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSMakeRange(0, attrString.length))
            toastLabel.attributedText = attrString.apply(word: subTitle, attrs: [.font: FontFamily.NanumSquareRound.regular.font(size: 11)])
        } else {
            toastLabel.text = message
        }
        
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
