//
//  TodayViewController.swift
//  FavoriteWidgetExtension
//
//  Created by 박상욱 on 2020/08/25.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: UIViewController, NCWidgetProviding {
   @IBOutlet private weak var collectionView: UICollectionView!
   var favArr: [InformationGasStaion] = []
   var colors: [UIColor?] = [UIColor(named: "MainColorAny"),
                            .systemOrange,
                            .systemPink,
                            .systemTeal,
                            .systemPurple
   ]
   
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      NCWidgetController().setHasContent(true,
                                         forWidgetWithBundleIdentifier: "com.OilPriceWhere.wheregasoline.FavoriteWidgetExtension")
   }
   
   func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
      guard let def = UserDefaults(suiteName: "group.wargi.oilPriceWhere"),
         let data = def.value(forKey: "FavoriteArr") as? Data else { return }
      
      if let infomations = try? JSONDecoder().decode(InformationGasStaions.self, from: data) {
         favArr = []
         infomations.allPriceList.forEach { info in
            if favArr.contains(where: { $0.id != info.id }) {
               favArr.append(info)
            }
         }
         collectionView.reloadData()
      }
      
      favArr.forEach { print($0.name) }

      completionHandler(NCUpdateResult.newData)
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
}

extension TodayViewController: UICollectionViewDataSource {
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return favArr.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WidgetFavoriteCollectionViewCell.identifier, for: indexPath) as? WidgetFavoriteCollectionViewCell else { fatalError() }
      
      cell.layer.cornerRadius = 10
      cell.oilPriceLabel.textColor = .white
      cell.brandImageView.image = logoImage(logoName: favArr[indexPath.row].brand)
//      cell.backView.backgroundColor = colors[indexPath.row]
      
      return cell
   }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      let spacing = (favArr.count - 1) * 3 + 6
      let width = (collectionView.bounds.width - CGFloat(spacing)) / CGFloat(favArr.count)
      print(collectionView.bounds.width, width)
      return CGSize(width: width, height: 59)
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
      return 3
   }
   
   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
      return 3
   }
}


