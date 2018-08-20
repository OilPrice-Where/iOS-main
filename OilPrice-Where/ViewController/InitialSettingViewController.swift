//
//  InitialSettingViewController.swift
//  OilPrice-Where
//
//  Created by 박소정 on 2018. 8. 19..
//  Copyright © 2018년 sangwook park. All rights reserved.
//

import UIKit

class InitialSettingViewController: UIViewController {

    @IBOutlet private weak var gasolinView : UIView!
    @IBOutlet private weak var dieselView : UIView!
    @IBOutlet private weak var lpgView : UIView!
    @IBOutlet private weak var premiumView : UIView!
    @IBOutlet private weak var scrollView : UIScrollView!
    lazy var scrollWidth = scrollView.bounds.size.width
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    // 확인 버튼 클릭 이벤트
    @IBAction private func okAction(_ sender: UIButton) {
        let selectedOil = scrollView.bounds.origin.x / scrollWidth
        
        switch selectedOil {
        case 1:
            DefaultData.shared.oilType = "D047"
        case 2:
            DefaultData.shared.oilType = "K015"
        case 3:
            DefaultData.shared.oilType = "B034"
        default:
            DefaultData.shared.oilType = "B027"
        }
    }
    
    // 왼쪽 버튼 클릭 이벤트
    @IBAction private func leftAction(_ sender: UIButton) {
        if scrollView.contentOffset.x > 0 {
            UIView.animate(withDuration: 0.2) {
                self.scrollView.contentOffset.x -= self.scrollWidth
            }
        }
    }
    
    // 오른쪽 버튼 클릭 이벤트
    @IBAction private func rightAction(_ sender: UIButton) {
        if scrollView.contentOffset.x < scrollWidth * 3 {
            UIView.animate(withDuration: 0.2) {
                self.scrollView.contentOffset.x += self.scrollWidth
            }
        }
    }
}
