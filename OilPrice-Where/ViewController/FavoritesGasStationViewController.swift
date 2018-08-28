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
    
    var oldFavoriteArr: [String] = [] // 이전 Favorites
    var oldOilType = "" // 이전 Oil Type
    
    @IBOutlet private weak var noneView : UIView! // None View
    @IBOutlet private weak var firstView : FavoriteView! // 1st Favorite View
    @IBOutlet private weak var secondView : FavoriteView! // 2nd Favorite View
    @IBOutlet private weak var thirdView : FavoriteView! // 3rd Favorite View
    
    @IBOutlet weak var scrollView: UIScrollView! // Scroll View
    @IBOutlet weak var pager: UIPageControl! // Page Controller
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        defaultSetting() // 초기 설정
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent // Status Bar Color
        pager.numberOfPages = DefaultData.shared.favoriteArr.count // Page Number
        
        // 이전 데이터와 중복 되거나, 새로운 오일 타입 설정 시 데이터를 다시 받아서 업데이트 시켜준다.
        if oldFavoriteArr != DefaultData.shared.favoriteArr || oldOilType != DefaultData.shared.oilType {
            viewHiddenSetting() // 처음 뷰의 isHidden 상태로 돌린다.
            setting() // 즐겨 찾기 된 주유소의 데이터를 셋팅 해준다.
        }
    }
    
    // 뷰가 없어 질 때 뷰의 이전 정보들을 저장 시킨다.
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        oldFavoriteArr = DefaultData.shared.favoriteArr // 이전 즐겨찾기 목록
        oldOilType = DefaultData.shared.oilType // 이전 오일 타입
    }
    
    // 초기 설정
    func defaultSetting() {
        // Page Controller 설정
        pager.currentPageIndicatorTintColor = UIColor.white // Page Controller Color
        pager.currentPage = 0 // 초기 Current Page
        
//        scrollView.layer.cornerRadius = 6 // ScrollView Coner Radius
        oldOilType = DefaultData.shared.oilType // Oil Type
    }
    
    // 처음 뷰의 isHidden 상태로 돌린다.
    func viewHiddenSetting() {
        firstView.isHidden = true
        secondView.isHidden = true
        thirdView.isHidden = true
        noneView.isHidden = false
    }
    
    // 즐겨찾기 수 만큼 뷰를 설정
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
    
    // 상세정보를 뷰에 입력
    func favoriteDataLoad(viewArr: [FavoriteView]) {
        noneView.isHidden = true // 데이터를 호출 하면 즐겨찾기가 있다는 뜻이므로 noneView를 hidden 시켜준다.
        
        for index in 0 ..< viewArr.count { // 뷰의 카운트 값(즐겨찾기 수)만큼 데이터를 읽어 온다.
            ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                             id: DefaultData.shared.favoriteArr[index]) {
                (result) in
                switch result {
                case .success(let favoriteData):
                    viewArr[index].isHidden = false // 생성되는 뷰의 isHidden값을 false로 변경
                    viewArr[index].configure(with: favoriteData.result.allPriceList[0]) // 뷰 정보 입력
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
