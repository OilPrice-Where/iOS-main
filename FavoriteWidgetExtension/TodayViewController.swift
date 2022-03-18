//
//  TodayViewController.swift
//  FavoriteWidgetExtension
//
//  Created by 박상욱 on 2020/08/25.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation
import KakaoSDKCommon
import KakaoSDKNavi
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
    @IBOutlet private weak var popupView: UIView!
    @IBOutlet private weak var popupTitleLabel: UILabel!
    @IBOutlet private weak var collectionView: UICollectionView!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var contentLabel: UILabel!
    
    var favArr: [InformationGasStaion] = []
    var tColors: [UIColor] = [UIColor(hexString: "#FFCB52"),
                              UIColor(hexString: "#5581F1"),
                              UIColor(hexString: "#FFE324"),
                              UIColor(hexString: "#FACD68"),
                              UIColor(hexString: "#1DE5E2")]
    
    var bColors: [UIColor] = [UIColor(hexString: "#FF7B02"),
                              UIColor(hexString: "#1153FC"),
                              UIColor(hexString: "#FFB533"),
                              UIColor(hexString: "#FC76B3"),
                              UIColor(hexString: "#B588F7xx")]
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        popupView.layer.cornerRadius = 10
        popupTitleLabel.textColor = .white
        
        KakaoSDK.initSDK(appKey: "b8e7f9ac5bf3c19414515867205f92aa")
        NCWidgetController().setHasContent(true,
                                           forWidgetWithBundleIdentifier: "com.OilPriceWhere.wheregasoline.FavoriteWidgetExtension")
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        guard let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere"),
              let data = def.value(forKey: "FavoriteArr") as? Data else {
                  completionHandler(NCUpdateResult.newData)
                  return
              }
        
        favArr = []
        var tempArr = [String]()
        
        if let infomations = try? JSONDecoder().decode(InformationGasStaions.self, from: data) {
            infomations.allPriceList.forEach { info in
                if !tempArr.contains(info.id) {
                    favArr.append(info)
                    tempArr.append(info.id)
                }
            }
        }
        
        collectionView.reloadData()
        
        completionHandler(NCUpdateResult.newData)
    }
    
    
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        guard let compactHeight = extensionContext?.widgetMaximumSize(for: .compact).height else { return }
        
        switch activeDisplayMode {
        case .compact:
            preferredContentSize = maxSize
        case .expanded:
            preferredContentSize = CGSize(width: maxSize.width, height: compactHeight * 1.5)
        default:
            fatalError()
        }
    }
    
    func getAppKey() -> String {
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
    func logoImage(logoName name: String?) -> UIImage? {
        guard let logoName = name else { return nil }
        switch logoName {
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
    
    // 위치 변환 ( Katec -> WGS84 )
    func convertKatecToWGS(with station: InformationGasStaion) -> CLLocationCoordinate2D {
        let convert = GeoConverter()
        let katecPoint = GeographicPoint(x: station.katecX, y: station.katecY)
        let wgsPoint = convert.convert(sourceType: .KATEC,
                                       destinationType: .WGS_84,
                                       geoPoint: katecPoint)
        
        return CLLocationCoordinate2D(latitude: wgsPoint!.y,
                                      longitude: wgsPoint!.x)
        
    }
    
    // 길안내 에러 발생
    func handleError(message: String) {
        popupView.isHidden = false
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.popupTitleLabel.text = message
            self.popupView.isHidden = true
        }
    }
}

extension TodayViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        extensionContext?.widgetLargestAvailableDisplayMode = favArr.count == 5 ? .expanded : .compact
        
        titleLabel.isHidden = !favArr.isEmpty
        contentLabel.isHidden = !favArr.isEmpty
        
        return favArr.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WidgetFavoriteCollectionViewCell.identifier, for: indexPath) as? WidgetFavoriteCollectionViewCell else { fatalError() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = cell.bounds
        gradientLayer.colors = [tColors[indexPath.row].cgColor, bColors[indexPath.row].cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 1.0)
        cell.layer.insertSublayer(gradientLayer, at: 0)
        
        cell.layer.cornerRadius = 8
        cell.oilPriceLabel.textColor = .white
        cell.oilPriceLabel.text = favArr[indexPath.row].name
        cell.brandImageView.image = logoImage(logoName: favArr[indexPath.row].brand)
        
        return cell
    }
}

extension TodayViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectStation = favArr[indexPath.row]
        let katecX = selectStation.katecX.rounded()
        let katecY = selectStation.katecY.rounded()
        
        let coordinator = convertKatecToWGS(with: selectStation)
        
        guard let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere"),
              let type = def.value(forKey: "NaviType") as? String else { return }
        
        switch type {
        case "kakao":
            let destination = NaviLocation(name: selectStation.name, x: "\(NSNumber(value: katecX))", y: "\(NSNumber(value: katecY))")
            let options = NaviOption(routeInfo: false)
            guard let navigateUrl = NaviApi.shared.navigateUrl(destination: destination, option: options) else { return }

            extensionContext?.open(navigateUrl, completionHandler: { [weak self] isSuccess in
                if !isSuccess {
                    self?.extensionContext?.open(NaviApi.webNaviInstallUrl, completionHandler: nil)
                }
            })
        case "tMap":
            let urlString = "tmap://?rGoName=\(selectStation.name)&rGoX=\(coordinator.longitude)&rGoY=\(coordinator.latitude)"
            
            guard let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let destinationURL = URL(string: encodedStr),
                  let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/431589174") else { return }
            
            extensionContext?.open(destinationURL, completionHandler: { [weak self] isSuccess in
                if !isSuccess {
                    self?.extensionContext?.open(appstoreURL, completionHandler: nil)
                }
            })
        case "kakaoMap":
            guard let destinationURL = URL(string: "kakaomap://route?ep=\(coordinator.latitude),\(coordinator.longitude)&by=CAR"),
            let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/304608425") else { return }
            
            extensionContext?.open(destinationURL, completionHandler: { [weak self] isSuccess in
                if !isSuccess {
                    self?.extensionContext?.open(appstoreURL, completionHandler: nil)
                }
            })
        default:
            let urlString = "nmap://navigation?dlat=\(coordinator.latitude)&dlng=\(coordinator.longitude)&dname=\(selectStation.name)&appname=com.oilpricewhere.wheregasoline"
            
            guard let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed),
                  let destinationURL = URL(string: encodedStr),
                  let appstoreURL = URL(string: "itms-apps://itunes.apple.com/app/311867728") else { return }
            
            extensionContext?.open(destinationURL, completionHandler: { [weak self] isSuccess in
                if !isSuccess {
                    self?.extensionContext?.open(appstoreURL, completionHandler: nil)
                }
            })
        }
    }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        guard var compactHeight = extensionContext?.widgetMaximumSize(for: .compact).height else { return .zero }
        compactHeight -= 20
        let spacing: CGFloat = 3
        let width = (collectionView.bounds.width) / 2 - spacing
        let height = (compactHeight) / 2 - spacing
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 6
    }
}


