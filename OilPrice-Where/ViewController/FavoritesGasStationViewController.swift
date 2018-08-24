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
    
    //    ["A0000015", "A0010167", "A0010172"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pager: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        
        pager.currentPage = 0
        pager.numberOfPages = DefaultData.shared.favoriteArr.count
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for index in 0 ..< DefaultData.shared.favoriteArr.count {
            slides.append(ScrollSlideView(frame: CGRect(x: view.frame.width * CGFloat(index),
                                                        y: 0,
                                                        width: view.frame.width,
                                                        height: view.frame.height)))
            scrollView.addSubview(slides[index])
        }
        createSlides()
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        print("***************************스크롤뷰 세로높이 = \(scrollView.frame.height)")
        print("***************************스크롤뷰 가로길이 = \(scrollView.frame.width)")
        scrollView.isPagingEnabled = true
        
        favoriteDataLoad()
    }
    
    func favoriteDataLoad() {
        for index in 0 ..< DefaultData.shared.favoriteArr.count {
            ServiceList.informationGasStaion(appKey: Preferences.getAppKey(),
                                             id: DefaultData.shared.favoriteArr[index]) { (result) in
                                                switch result {
                                                case .success(let favoriteData):
//                                                    self.slides[index].configure(with: favoriteData.result.allPriceList)
//                                                    self.informationGasStaions.append(favoriteData.result.allPriceList)
                                                    self.slides[index].setNeedsLayout()
                                                    self.slides[index].layoutIfNeeded()
                                                case .error(let error):
                                                    print("ERRRROROROROROROROR")
                                                    print(error)
                                                }
            }
        }
    }
    //     슬라이드뷰 만들기
    func createSlides() {
        var scrollSlides: [ScrollSlideView] = []
        
        for _ in 0 ..< DefaultData.shared.favoriteArr.count {
            scrollSlides.append(Bundle.main.loadNibNamed("ScrollSlideView", owner: self, options: nil)?.first as! ScrollSlideView)
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
