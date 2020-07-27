//
//  MainListVC+TableView.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/27.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Foundation

// MARK: - UITableView
extension MainListViewController: UITableViewDataSource {
   func numberOfSections(in tableView: UITableView) -> Int {
      guard let stationCount = DefaultData.shared.data?.count else { return 0 }
      return stationCount
   }
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 1
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard var gasStations = DefaultData.shared.data else { return UITableViewCell() }
      
      if distanceSortButton.isSelected {
         gasStations = sortData
      }
      
      let cell = tableView.dequeueReusableCell(withIdentifier: "GasStationCell") as! GasStationCell
      
      cell.addGestureRecognize(self, action: #selector(self.viewMapAction(annotionIndex:)))
      cell.configure(with: gasStations[indexPath.section])
      
      if selectIndexPath?.section == indexPath.section {
         cell.stationView.stackView.isHidden = false
      }
      
      return cell
   }
}

// MARK: - UITableViewDelegate
extension MainListViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let selectPath = self.selectIndexPath else {
         let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
         cell.stationView.stackView.isHidden = false
         cell.selectionStyle = .none
         self.selectIndexPath = indexPath
         
         tableView.reloadData()
         return
      }
      if indexPath.section != selectPath.section {
         if let newCell = tableView.cellForRow(at: indexPath) as? GasStationCell {
            newCell.selectionStyle = .none
            newCell.stationView.stackView.isHidden = false
         }
         if let oldCell = tableView.cellForRow(at: selectPath) as? GasStationCell {
            oldCell.stationView.stackView.isHidden = true
         }
         self.selectIndexPath = indexPath
      } else {
         if let cell = tableView.cellForRow(at: indexPath) as? GasStationCell {
            if cell.stationView.stackView.isHidden {
               cell.stationView.stackView.isHidden = false
            } else {
               oldIndexPath = selectIndexPath!
               cell.stationView.stackView.isHidden = true
               selectIndexPath = nil
            }
         }
      }
      tableView.reloadData()
   }
   
   // cell의 높이 설정
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      guard let selectSection = self.selectIndexPath?.section else { return 110 }
      // 선택된 셀의 높이와 비선택 셀의 높이 설정
      return indexPath.section == selectSection ? 164 : 110
   }
   
   // 섹션 사이의 값 설정
   func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
      // 처음 섹션일 때 가격순, 거리순 정렬 버튼 삽입을 위해 조금 더 높게 설정
      return section == 0 ? 30 : 12
   }
   
   // heightForFooterInSection
   func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
      return 0.00001
   }
}
