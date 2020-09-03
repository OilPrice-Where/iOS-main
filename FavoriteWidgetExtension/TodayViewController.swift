//
//  TodayViewController.swift
//  FavoriteWidgetExtension
//
//  Created by 박상욱 on 2020/08/25.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import TMapSDK
import KakaoNavi
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding, TMapTapiDelegate {
   @IBOutlet private weak var collectionView: UICollectionView!
   @IBOutlet private weak var titleLabel: UILabel!
   @IBOutlet private weak var contentLabel: UILabel!
   
   var favArr: [InformationGasStaion] = []
   var colors: [UIColor?] = [UIColor(named: "MainColorAny"),
                            .systemOrange,
                            .systemPink,
                            .systemTeal,
                            .systemPurple
   ]
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      TMapApi.setSKTMapAuthenticationWithDelegate(self, apiKey: "219c2c34-cdd2-45d3-867b-e08c2ea97810")
      NCWidgetController().setHasContent(true,
                                         forWidgetWithBundleIdentifier: "com.OilPriceWhere.wheregasoline.FavoriteWidgetExtension")
      
      extensionContext?.widgetMaximumSize(for: .expanded)
   }
   
   func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
      guard let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere"),
         let data = def.value(forKey: "FavoriteArr") as? Data else {
             completionHandler(NCUpdateResult.newData)
            return
      }
      print("#1")
      
      favArr = []
      var tempArr = [String]()
      
      if let infomations = try? JSONDecoder().decode(InformationGasStaions.self, from: data) {
         print("#2", infomations)
         infomations.allPriceList.forEach { info in
            if !tempArr.contains(info.id) {
               favArr.append(info)
               tempArr.append(info.id)
            }
         }
      }
      
      collectionView.reloadData()
      favArr.forEach { print($0.name) }

      completionHandler(NCUpdateResult.newData)
   }
   
   
   
   func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
      
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
   func handleError(error: Error?) {
      if let error = error as NSError? {
         print(error)
         let alert = UIAlertController(title: title!,
                                       message: error.localizedFailureReason,
                                       preferredStyle: .alert)
         alert.addAction(UIAlertAction(title: "확인", style: .cancel, handler: nil))
         present(alert, animated: true, completion: nil)
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
      
      cell.layer.cornerRadius = 10
      cell.oilPriceLabel.textColor = .white
      cell.oilPriceLabel.text = favArr[indexPath.row].name
      cell.brandImageView.image = logoImage(logoName: favArr[indexPath.row].brand)
      cell.backView.backgroundColor = colors[indexPath.row]
      
      return cell
   }
}

extension TodayViewController: UICollectionViewDelegate {
   func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
      let selectStation = favArr[indexPath.row]
      let katecX = selectStation.katecX.rounded()
      let katecY = selectStation.katecY.rounded()
      print(selectStation.name, katecX, katecY)
      guard let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere"),
         let type = def.value(forKey: "NaviType") as? String else { return }
      
      print(type)
      
      switch type {
      case "kakao":
         let destination = KNVLocation(name: selectStation.name,
                                       x: NSNumber(value: katecX),
                                       y: NSNumber(value: katecY))
         let options = KNVOptions()
         options.routeInfo = false
         let params = KNVParams(destination: destination,
                                options: options)
         KNVNaviLauncher.shared().navigate(with: params) { (error) in
            self.handleError(error: error)
         }
      default:
         let coordinator = convertKatecToWGS(with: selectStation)
         
         if TMapApi.isTmapApplicationInstalled() {
            let _ = TMapApi.invokeRoute(selectStation.name, coordinate: coordinator)
         } else {
            let alert = UIAlertController(title: "T Map이 없습니다.",
                                          message: "다운로드 페이지로 이동하시겠습니까?",
                                          preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK",
                                         style: .default) { (_) in
                                          guard let url = URL(string: TMapApi.getTMapDownUrl()) else {
                                             return
                                          }
                                          
                                          self.extensionContext?.open(url, completionHandler: nil)
            }
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            
            present(alert, animated: true, completion: nil)
         }
      }
   }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let cal = favArr.count.isMultiple(of: 2) ? 1 : 0
      let spacing = CGFloat(cal * 3 + 6)
      let width = (collectionView.bounds.width - spacing) / 2
      let height = (collectionView.bounds.height - spacing) / 2
      
      return CGSize(width: width, height: height)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 3
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 3
   }
}


