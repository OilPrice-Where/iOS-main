//
//  GasStationCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2018. 7. 25..
//  Copyright © 2018년 sangwook park. All rights reserved.
//
import UIKit

// 메인페이지의 리스트 부분에서 받아오는 주유소 목록을 나타내는 셀
// Cell의 ContentView내부에 stationView를 보여준다.
class GasStationCell: UITableViewCell {

    @IBOutlet weak var stationView : GasStationView!
    let path = UIBezierPath()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stationView.favoriteButton.layer.cornerRadius = 6 // 즐겨찾기 버튼 외곽선 Radius 값 설정
        stationView.annotationButton.layer.cornerRadius = 6 // 경로보기 버튼 외곽선 Radius 값 설정
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    // 셀이 재사용 될 때 stationView의 stackView 히든
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationView.stackView.isHidden = true
    }
    
    // 메뉴 명, 설명, 가격, 이미지 삽입
    //stationView의 외곽선 설정
    func configure(with gasStation: GasStation) {
        self.stationView.configure(with: gasStation) // 주유소 정보 설정
        self.stationView.layer.cornerRadius = 10 // // 외곽선의 cornerRadius
        
    }
}
