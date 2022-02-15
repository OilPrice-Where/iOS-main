//
//  MainListHeaderView.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/17.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

final class MainListHeaderView: UIView {
    //MARK: - Properties
    let addressView = AddressView()
    let priceView = PriceView()
    let emptyView = UIView()
    
    //MARK: - Initializer
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Configure UI
    func makeUI() {
        backgroundColor = Asset.Colors.mainColor.color
        
        addSubview(addressView)
        addSubview(priceView)
        addSubview(emptyView)
        
        addressView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(57.5)
        }
        
        priceView.snp.makeConstraints {
            $0.top.equalTo(addressView.snp.bottom)
            $0.left.right.equalToSuperview().inset(20)
            $0.height.equalTo(162)
        }
        
        emptyView.snp.makeConstraints {
            $0.top.equalTo(priceView.snp.bottom).offset(20)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    func fetchData(getCode: String?) {
        addressView.fetch(geoCode: getCode)
        priceView.fetchAverageCosts()
    }
}

/*
/// 스크롤 옵셋에 따른 헤더뷰 위치 변경
///
/// - 코드 리펙토링 필요
func scrollViewDidScroll(_ scrollView: UIScrollView) {
   if scrollView == tableView {
      let setHeaderViewConstraint = headerViewConstraint.constant - scrollView.contentOffset.y
      if (self.lastContentOffset > scrollView.contentOffset.y) {
         if scrollView.contentOffset.y <= 0 {
            if -(setHeaderViewConstraint) >= 0 {
               headerViewConstraint.constant = setHeaderViewConstraint
               scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
            }else {
               headerViewConstraint.constant = 0
            }
         }
      }
      else if (self.lastContentOffset < scrollView.contentOffset.y) {
         if -(setHeaderViewConstraint) >= headerView.frame.size.height {
            headerViewConstraint.constant = -(headerView.frame.size.height)
         }else if -(setHeaderViewConstraint) >= 0{
            headerViewConstraint.constant = setHeaderViewConstraint
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
         }else{
            headerViewConstraint.constant = 0
            scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
         }
      }
      
      // 현재 테이블 뷰 컨텐츠 옵션의 위치 저장
      self.lastContentOffset = scrollView.contentOffset.y
   }
}
 */
