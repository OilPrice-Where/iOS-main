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
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pager: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pager.currentPage = 0
        pager.numberOfPages = slides.count
        
    }
    
    // 슬라이드뷰 만들기
    func createSlides() -> [ScrollSlideView] {
        
        let slide1:ScrollSlideView = Bundle.main.loadNibNamed("ScrollSlideView", owner: self, options: nil)?.first as! ScrollSlideView
//        slide1.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        
        let slide2:ScrollSlideView = Bundle.main.loadNibNamed("ScrollSlideView", owner: self, options: nil)?.first as! ScrollSlideView
        
        let slide3:ScrollSlideView = Bundle.main.loadNibNamed("ScrollSlideView", owner: self, options: nil)?.first as! ScrollSlideView
        
        
        return [slide1, slide2, slide3]
    }
    
    
    func setupSlideScrollView(slides : [ScrollSlideView]) {
        
//        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: scrollView.frame.height)
        print("***************************스크롤뷰 세로높이 = \(scrollView.frame.height)")
        print("***************************스크롤뷰 가로길이 = \(scrollView.frame.width)")
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
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
