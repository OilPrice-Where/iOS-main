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
   var colors: [UIColor] = [UIColor(red: 88, green: 86, blue: 214, alpha: 1.0),
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
         let data = def.value(forKey: "FavoriteArr") as? [String] else {
            print("#1")
            completionHandler(NCUpdateResult.noData)
            return
      }
      
      print("#2")
      
      data.forEach { [weak self] id in
         guard let strongSelf = self else { return }
         let session = URLSession(configuration: .default)
         let url = URL(string: API.detailById(appKey: strongSelf.getAppKey(), id: id).urlString)
         print("#3", url)
         if let url = url {
            let task = session.dataTask(with: url) { (infoData, res, err) in
               if let error = err {
                  print(error.localizedDescription)
                  completionHandler(NCUpdateResult.noData)
                  return
               }
               print("#4", infoData)
               if let data = infoData {
                  do {
                     let info = try JSONDecoder().decode(InformationOilStationResult.self, from: data)
                     strongSelf.favArr.append(info.result.allPriceList[0])
                     strongSelf.collectionView.reloadData()
                     print(info)
                  } catch {
                     print(error.localizedDescription)
                  }
               }
            }
            
            task.resume()
         }
      }
      
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
}

extension TodayViewController: UICollectionViewDataSource {
   func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
      return favArr.count
   }
   
   func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
      guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WidgetFavoriteCollectionViewCell.identifier, for: indexPath) as? WidgetFavoriteCollectionViewCell else { fatalError() }
      
      cell.layer.cornerRadius = 10
      cell.backView.backgroundColor = colors[indexPath.row]
      
      return cell
   }
}

extension TodayViewController: UICollectionViewDelegateFlowLayout {
//   func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//      let count = CGFloat(favArr.count)
//      let width = (collectionView.bounds.width - count * 10 - 10) / count
//      return CGSize(width: width, height: width)
//   }
}


