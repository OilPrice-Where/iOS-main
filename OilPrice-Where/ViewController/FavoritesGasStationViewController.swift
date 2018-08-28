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
    
    var oldFavoriteArr: [String] = []
    lazy var contentViewArr: [UIView] = [firstContentView,
                                         secondContentView,
                                         thirdContentView,
                                         noneContentView]
    
    @IBOutlet private weak var noneView : UIView!
    @IBOutlet private weak var firstView : FavoriteView!
    @IBOutlet private weak var secondView : FavoriteView!
    @IBOutlet private weak var thirdView : FavoriteView!
    
    @IBOutlet weak var firstContentView: UIView!
    @IBOutlet weak var secondContentView: UIView!
    @IBOutlet weak var thirdContentView: UIView!
    @IBOutlet weak var noneContentView: UIView!
    
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pager: UIPageControl!
    
    @IBAction func pageChanged(_ sender: UIPageControl) {
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pager.currentPageIndicatorTintColor = UIColor.white
        pager.pageIndicatorTintColor = UIColor.lightGray
        pager.currentPage = 0

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
        firstContentView.isHidden = true
        secondContentView.isHidden = true
        thirdContentView.isHidden = true
        noneContentView.isHidden = false
    }

    func favoriteDataLoad(viewArr: [FavoriteView]) {
        noneContentView.isHidden = true
        
        for index in 0 ..< viewArr.count {
            ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                             id: DefaultData.shared.favoriteArr[index]) {
                (result) in
                switch result {
                case .success(let favoriteData):
                    self.contentViewArr[index].isHidden = false
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
        let x = scrollView.contentOffset.x + (width / 2.0)
        let newPage = Int(x / width)
        
        if pager.currentPage != newPage {
            pager.currentPage = newPage
        }
//        let page = Int((scrollView.contentOffset.x + width / 2) / width)
//        pager.currentPage = newPage
    }
}
