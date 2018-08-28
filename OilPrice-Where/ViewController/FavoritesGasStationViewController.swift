//
//  FavoritesGasStationViewController.swift
//  OilPrice-Where
//
//  Created by Himchan Park on 2018. 8. 22..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit
import CoreLocation

class FavoritesGasStationViewController: UIViewController {
    
    var slides:[ScrollSlideView] = []
    var informationGasStaions: [InformationGasStaion?] = []
    var oldFavoriteArr: [String] = []
    
    @IBOutlet private weak var noneView : UIView!
    @IBOutlet private weak var firstView : FavoriteView!
    @IBOutlet private weak var secondView : FavoriteView!
    @IBOutlet private weak var thirdView : FavoriteView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pager: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pager.currentPageIndicatorTintColor = UIColor.white
        pager.currentPage = 0
        
        scrollView.layer.cornerRadius = 6
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
        pager.numberOfPages = DefaultData.shared.favoriteArr.count
        if oldFavoriteArr != DefaultData.shared.favoriteArr {
            basicSetting()
            setting()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        oldFavoriteArr = DefaultData.shared.favoriteArr
    }
    
    func setting() {
        switch DefaultData.shared.favoriteArr.count {
        case 1:
            favoriteDataLoad(viewArr: [firstView])
        case 2:
            favoriteDataLoad(viewArr: [firstView, secondView])
        case 3:
            favoriteDataLoad(viewArr: [firstView, secondView, thirdView])
        default:
            break
        }
    }
    
    func basicSetting() {
        firstView.isHidden = true
        secondView.isHidden = true
        thirdView.isHidden = true
        noneView.isHidden = false
    }

    func favoriteDataLoad(viewArr: [FavoriteView]) {
        noneView.isHidden = true
        
        for index in 0 ..< viewArr.count {
            ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                             id: DefaultData.shared.favoriteArr[index]) {
                (result) in
                switch result {
                case .success(let favoriteData):
                    viewArr[index].isHidden = false
                    viewArr[index].configure(with: favoriteData.result.allPriceList[0])
                    if index == 0 {
                        viewArr[0].alpha = 1
                    }
                case .error(let error):
                    print(error)
                }
            }
        }
    }
}

// PageControl 설정
extension FavoritesGasStationViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width / 2) / width)
        pager.currentPage = page
    }
}
