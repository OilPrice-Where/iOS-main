////
////  MainListVC+TableView.swift
////  OilPrice-Where
////
////  Created by 박상욱 on 2020/07/27.
////  Copyright © 2020 sangwook park. All rights reserved.
////
//
//import Foundation
//
//// MARK: - UITableView
//extension MainListViewController: UITableViewDataSource {
//    func numberOfSections(in tableView: UITableView) -> Int {
//        guard let station = try? DefaultData.shared.stationsSubject.value() else { return 0 }
//        return station.count
//    }
//    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 1
//    }
//    
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        guard let targetArr = try? DefaultData.shared.stationsSubject.value() else {
//            return UITableViewCell()
//        }
//        
//        let cell = tableView.dequeueReusableCell(withType: GasStationCell.self, for: indexPath)
//        
//        let stations = distanceSortButton.isSelected ? sortData : targetArr
//        
//        cell.stationView.stackView.isHidden = selectIndexPath?.section != indexPath.section
//        cell.addGestureRecognize(self, action: #selector(viewMapAction(annotionIndex:)))
//        cell.configure(with: stations[indexPath.section])
//        
//        return cell
//    }
//}
//
//// MARK: - UITableViewDelegate
//extension MainListViewController: UITableViewDelegate {
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        guard let selectPath = selectIndexPath else {
//            let cell = tableView.cellForRow(at: indexPath) as! GasStationCell
//            cell.stationView.stackView.isHidden = false
//            cell.selectionStyle = .none
//            selectIndexPath = indexPath
//            
//            tableView.reloadData()
//            return
//        }
//        if indexPath.section != selectPath.section {
//            if let newCell = tableView.cellForRow(at: indexPath) as? GasStationCell {
//                newCell.selectionStyle = .none
//                newCell.stationView.stackView.isHidden = false
//            }
//            if let oldCell = tableView.cellForRow(at: selectPath) as? GasStationCell {
//                oldCell.stationView.stackView.isHidden = true
//            }
//            selectIndexPath = indexPath
//        } else {
//            if let cell = tableView.cellForRow(at: indexPath) as? GasStationCell {
//                if cell.stationView.stackView.isHidden {
//                    cell.stationView.stackView.isHidden = false
//                } else {
//                    oldIndexPath = selectIndexPath!
//                    cell.stationView.stackView.isHidden = true
//                    selectIndexPath = nil
//                }
//            }
//        }
//        tableView.reloadData()
//    }
//    
//    // cell의 높이 설정
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        guard let selectSection = selectIndexPath?.section else { return 110 }
//        // 선택된 셀의 높이와 비선택 셀의 높이 설정
//        return indexPath.section == selectSection ? 164 : 110
//    }
//    
//    // 섹션 사이의 값 설정
//    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        let sortedViewHeight: CGFloat = 30
//        let defaultViewHeight: CGFloat = 12
//        
//        // 처음 섹션일 때 가격순, 거리순 정렬 버튼 삽입을 위해 조금 더 높게 설정
//        return section == 0 ? sortedViewHeight : defaultViewHeight
//    }
//    
//    // heightForFooterInSection
//    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
//        return 0.00001
//    }
//}
