//
//  MenuViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/03.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

//MARK: MenuViewModel
final class MenuViewModel {
    //MARK: - Properties
    var cancelBag = Set<AnyCancellable>()
    let output = Output()
    
    //MARK: Initializer
    init() {
        bind()
    }
    
    //MARK: Binding..
    func bind() {
        
    }
}

//MARK: - I/O & ErrorMenuViewModel
extension MenuViewModel {
    struct Output {
        enum PresentType {
            case findBrand
            case cardSale
            case history
            case aboutUs
        }
        
        //MARK: Functions..
        func fetchReview() {
            let id = "1435350344"
            if let reviewURL = URL(string: "itms-apps://itunes.apple.com/app/itunes-u/id\(id)?ls=1&mt=8&action=write-review"), UIApplication.shared.canOpenURL(reviewURL) {
                // 유효한 URL인지 검사
                if #available(iOS 10.0, *) { //iOS 10.0부터 URL를 오픈하는 방법이 변경 되었습니다.
                    UIApplication.shared.open(reviewURL, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(reviewURL)
                }
            }
        }
        
        func fetchNavigationController(type: PresentType) -> UINavigationController {
            var vc: UIViewController?
            
            switch type {
            case .findBrand:
                break
            case .cardSale:
                var saleVC = SettingEditSalePriceVC()
                vc = saleVC
            case .history:
                let historiesVC = HistoriesVC()
                vc = historiesVC
            case .aboutUs:
                break
            }
            
            let navi = UINavigationController(rootViewController: vc!)
            
            navi.navigationBar.tintColor = .white
            navi.navigationBar.titleTextAttributes = [.font: FontFamily.NanumSquareRound.bold.font(size: 17),
                                                                       .foregroundColor: UIColor.white]
            navi.navigationBar.backgroundColor = Asset.Colors.mainColor.color
            
            return navi
        }
    }
}
