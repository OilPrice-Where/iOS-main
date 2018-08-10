//
//  Converter.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 8. 8..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import Foundation
import CoreLocation

struct KatecPoint {
    let x: Double
    let y: Double
}

// 위치 변환
final class Converter {
    // 위치 변환 ( WGS84 -> Katec )
    static func convertWGS84ToKatec(coordinate: CLLocationCoordinate2D) -> KatecPoint {
        let convert = GeoConverter()
        let wgsPoint = GeographicPoint(x: coordinate.longitude, y: coordinate.latitude)
        let tmPoint = convert.convert(sourceType: .WGS_84, destinationType: .TM, geoPoint: wgsPoint)
        let katecPoint = convert.convert(sourceType: .TM, destinationType: .KATEC, geoPoint: tmPoint!)
        
        return KatecPoint(x: katecPoint!.x, y: katecPoint!.y)
    }
    
    // 위치 변환 ( Katec -> WGS84 )
    static func convertKatecToWGS(katec: KatecPoint) -> CLLocationCoordinate2D {
        let convert = GeoConverter()
        let katecPoint = GeographicPoint(x: katec.x, y: katec.y)
        let wgsPoint = convert.convert(sourceType: .KATEC,
                                       destinationType: .WGS_84,
                                       geoPoint: katecPoint)
        
        return CLLocationCoordinate2D(latitude: wgsPoint!.y,
                                      longitude: wgsPoint!.x)
        
    }
}

// App 기본 설정
final class Preferences {
    
    // App Key
    static func getAppKey() -> String {
        var appKey = ""
        
        switch arc4random_uniform(6) {
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
    
    // 로고 이미지
    static func logoImage(logoName name: String) -> UIImage? {
        switch name {
        case "SKE":
            return UIImage(named: "LogoSKEnergy")
        case "GSC":
            return UIImage(named: "LogoGSCaltex")
        case "HDO":
            return UIImage(named: "LogoOilBank")
        case "SOL":
            return UIImage(named: "LogoSOil")
        case "RTO":
            return UIImage(named: "LogoFrugalOil")
        case "RTX":
            return UIImage(named: "LogoExpresswayOil")
        case "NHO":
            return UIImage(named: "LogoNHOil")
        case "ETC":
            return UIImage(named: "LogoPersonalOil")
        case "E1G":
            return UIImage(named: "LogoEnergyOne")
        case "SKG":
            return UIImage(named: "LogoSKGas")
        default:
            return nil
        }
    }
    
    static func oil(name: String) -> String {
        switch name {
        case "휘발유":
            return "B027"
        case "고급 휘발유":
            return "B034"
        case "경유":
            return "D047"
        case "실내등유":
            return "C004"
        default: // 자동차 부탄
            return "K015"
        }
    }
    
    static func oil(code: String) -> String {
        switch code {
        case "B027":
            return "휘발유"
        case "B034":
            return "고급휘발유"
        case "D047":
            return "경유"
        case "C004":
            return "실내등유"
        default: // K015
            return "자동차부탄"
        }
    }
    
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
}
