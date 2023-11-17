//
//  Converter.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import SwiftUI
import CoreLocation

// 카텍 좌표 저장
struct KatecPoint {
    let x: Double
    let y: Double
}

enum NaviType: String {
    case kakao = "kakao"
    case kakaoMap = "kakaoMap"
    case tMap = "tMap"
    case naver = "naverMap"
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
    
    // 받아오는 Logo Code값을 Image로 변환해주는 함수
    // ex) SKE -> UIImage(named: "LogoSKEnergy") // SK 로고이미지
    static func logoImage(logoName name: String?) -> UIImage? {
        guard let logoName = name else { return nil }
        switch logoName {
        case "SKE":
            return Asset.Images.logoSKEnergy.image
        case "GSC":
            return Asset.Images.logoGSCaltex.image
        case "HDO":
            return Asset.Images.logoOilBank.image
        case "SOL":
            return Asset.Images.logoSOil.image
        case "RTO":
            return Asset.Images.logoFrugalOil.image
        case "RTX":
            return Asset.Images.logoExpresswayOil.image
        case "NHO":
            return Asset.Images.logoNHOil.image
        case "ETC":
            return Asset.Images.logoPersonalOil.image
        case "E1G":
            return Asset.Images.logoEnergyOne.image
        case "SKG":
            return Asset.Images.logoSKGas.image
        default:
            return nil
        }
    }
    
    // 받아오는 Logo Code값을 Image로 변환해주는 함수
    // ex) SKE -> UIImage(named: "LogoSKEnergy") // SK 로고이미지
    static func logoImage(name: String?) -> Image? {
        guard let logoName = name else { return nil }
        switch logoName {
        case "SKE":
            return Asset.Images.logoSKEnergy.swiftUIImage
        case "GSC":
            return Asset.Images.logoGSCaltex.swiftUIImage
        case "HDO":
            return Asset.Images.logoOilBank.swiftUIImage
        case "SOL":
            return Asset.Images.logoSOil.swiftUIImage
        case "RTO":
            return Asset.Images.logoFrugalOil.swiftUIImage
        case "RTX":
            return Asset.Images.logoExpresswayOil.swiftUIImage
        case "NHO":
            return Asset.Images.logoNHOil.swiftUIImage
        case "ETC":
            return Asset.Images.logoPersonalOil.swiftUIImage
        case "E1G":
            return Asset.Images.logoEnergyOne.swiftUIImage
        case "SKG":
            return Asset.Images.logoSKGas.swiftUIImage
        default:
            return nil
        }
    }
    
    // Oil Type을 Oil Code로 변환 함수
    // ex) 휘발유 -> B027
    static func oil(name: String) -> String {
        switch name {
        case "휘발유":
            return "B027"
        case "고급휘발유":
            return "B034"
        case "경유":
            return "D047"
        case "LPG":
            return "K015"
        default:
            return ""
        }
    }
    
    // Oil Code를 Oil Type으로 변환 함수
    // ex) B027 -> 휘발유
    static func oil(code: String) -> String {
        switch code {
        case "B027":
            return "휘발유"
        case "B034":
            return "고급휘발유"
        case "D047":
            return "경유"
        case "K015":
            return "LPG"
        default:
            return ""
        }
    }
    
    // Brand Type을 Brand Code로 변환 함수
    // ex) SK에너지 -> SKE
    
    static func brand(name: String) -> String {
        switch name {
        case "SK에너지":
            return "SKE"
        case "GS칼텍스":
            return "GSC"
        case "현대오일뱅크":
            return "HDO"
        case "S-OIL":
            return "SOL"
        case "자영알뜰":
            return "RTO"
        case "고속도로알뜰":
            return "RTX"
        case "농협알뜰":
            return "NHO"
        case "자가상표":
            return "ETC"
        case "E1":
            return "E1G"
        case "SK가스":
            return "SKG"
        default:
            return "ALL"
        }
    }
    
    // Brand Code를 Brand Type으로 변환 함수
    // ex) B027 -> 휘발유
    static func brand(code: String) -> String {
        switch code {
        case "SKE":
            return "SK에너지"
        case "GSC":
            return "GS칼텍스"
        case "HDO":
            return "현대오일뱅크"
        case "SOL":
            return "S-OIL"
        case "RTO":
            return "자영알뜰"
        case "RTX":
            return "고속도로알뜰"
        case "NHO":
            return "농협알뜰"
        case "ETC":
            return "자가상표"
        case "E1G":
            return "E1"
        case "SKG":
            return "SK가스"
        default:
            return "전체"
        }
    }
    
    static func saleBrand(name: String) -> String {
        switch name {
        case "GS칼텍스":
            return "GSC"
        case "현대오일뱅크":
            return "HDO"
        case "S-OIL":
            return "SOL"
        case "알뜰주유소":
            return "RTO"
        case "농협":
            return "NHO"
        case "E1":
            return "E1G"
        default:
            return "SK"
        }
    }
    
    // String으로 표시 된 거리를 Int값으로 반환
    // ex) 1KM -> 1000
    static func distanceKM(KM: String) -> Int {
        switch KM {
        case "1KM":
            return 1000
        case "3KM":
            return 3000
        default: // 5KM
            return 5000
        }
    }
    
    static func distanceKM(KM: Int) -> String {
        switch KM {
        case 1000:
            return "1KM"
        case 3000:
            return "3KM"
        default: // 5KM
            return "5KM"
        }
    }
        
    // 네비게이션 디스플레이 네임
    static func navigation(type: String) -> String {
        switch type {
        case "kakao":
            return "카카오내비"
        case "kakaoMap":
            return "카카오맵"
        case "tMap":
            return "티맵"
        default:
            return "네이버지도"
        }
    }
    
    // 네비게이션 타입
    static func navigation(name: String) -> String {
        switch name {
        case "카카오내비":
            return "kakao"
        case "카카오맵":
            return "kakaoMap"
        case "티맵":
            return "tMap"
        default:
            return "naverMap"
        }
    }
    
    // Int값을 원화 사이의 ','를 넣어주는 함수
    static func priceToWon(price: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let stringPrice = formatter.string(from: NSNumber(integerLiteral: price))
        
        return stringPrice ?? "0"
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
    
    static func distance(km: Double) -> String {
        return km < 1000 ? "\(Int(km))m" : String(format: "%.1fkm", km / 1000)
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

// 반올림
extension Double {
    /// Rounds the double to decimal places value
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// 기종 확인
extension UIDevice {
    public var isiPhoneX: Bool {
        if UIDevice.current.userInterfaceIdiom == UIUserInterfaceIdiom.phone &&
            (UIScreen.main.bounds.size.height > 736 || UIScreen.main.bounds.size.width > 414) {
            return true
        }
        return false
    }
}
