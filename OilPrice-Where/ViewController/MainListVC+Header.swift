//
//  MainListVC+Header.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation

// MARK: - UITableViewDelegate
extension MainListViewController {
   // HeaderView 설정
   func setAverageCosts() {
      firebaseUtility.getAverageCost(productName: "gasolinCost") { (data) in
         self.mainProductCostLabel.text = data["price"] as? String ?? ""
         self.mainProductTitleLabel.text = data["productName"] as? String ?? ""
         if data["difference"] as? Bool ?? true {
            self.mainProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
         }else {
            self.mainProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
         }
      }
      firebaseUtility.getAverageCost(productName: "dieselCost") { (data) in
         self.secondProductCostLabel.text = data["price"] as? String ?? ""
         self.secondProductTitleLabel.text = data["productName"] as? String ?? ""
         if data["difference"] as? Bool ?? true {
            self.secondProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
         }else {
            self.secondProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
         }
         
      }
      firebaseUtility.getAverageCost(productName: "lpgCost") { (data) in
         self.thirdProductCostLabel.text = data["price"] as? String ?? ""
         self.thirdProductTitleLabel.text = data["productName"] as? String ?? ""
         if data["difference"] as? Bool ?? true {
            self.thirdProductImageView.image = #imageLiteral(resourceName: "priceUpIcon")
         } else {
            self.thirdProductImageView.image = #imageLiteral(resourceName: "priceDownIcon")
         }
      }
   }
}

extension MainListViewController: UIScrollViewDelegate {
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
}
