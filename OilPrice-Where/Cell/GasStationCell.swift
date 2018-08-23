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
    var tapGesture = UITapGestureRecognizer()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        stationView.favoriteButton.layer.cornerRadius = 6 // 즐겨찾기 버튼 외곽선 Radius 값 설정
        stationView.annotationButtonView.layer.cornerRadius = 6 // 경로보기 버튼 외곽선 Radius 값 설정
        stationView.annotationButtonView.layer.borderColor = UIColor(named: "MainColor")?.cgColor
        stationView.annotationButtonView.layer.borderWidth = 1.5
        stationView.layer.masksToBounds = false
        stationView.layer.shadowColor = UIColor.darkGray.cgColor
        stationView.layer.shadowOpacity = 0.8
        stationView.layer.shadowOffset = CGSize(width: 2, height: 2)
        stationView.layer.shadowRadius = 2
        
        stationView.layer.shadowPath = UIBezierPath(roundedRect: CGRect(x: stationView.bounds.origin.x,
                                                                             y: stationView.bounds.origin.y, width: stationView.bounds.size.width, height: 110), cornerRadius: 10).cgPath
        stationView.layer.shouldRasterize = true
        
        stationView.layer.rasterizationScale = UIScreen.main.scale
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    
    // 셀이 재사용 될 때 stationView의 stackView 히든
    override func prepareForReuse() {
        super.prepareForReuse()
        self.stationView.stackView.isHidden = true
        
        stationView.layer.masksToBounds = false
        stationView.layer.shadowColor = UIColor.darkGray.cgColor
        stationView.layer.shadowOpacity = 0
        stationView.layer.shadowOffset = CGSize(width: 2, height: 2)
        stationView.layer.shadowRadius = 0.1
        
        stationView.layer.shadowPath = UIBezierPath(roundedRect: stationView.bounds, cornerRadius: 10).cgPath
        stationView.layer.shouldRasterize = true
        
        stationView.layer.rasterizationScale = UIScreen.main.scale
        selectionStyle = .none
    }
    
    // 메뉴 명, 설명, 가격, 이미지 삽입
    //stationView의 외곽선 설정
    func configure(with gasStation: GasStation) {
        self.stationView.configure(with: gasStation) // 주유소 정보 설정
        self.stationView.layer.cornerRadius = 10 // // 외곽선의 cornerRadius
        
    }
    
    func addGestureRecognize(_ target: Any?, action: Selector) {
        tapGesture = UITapGestureRecognizer(target: target, action: action)
        stationView.annotationButtonView.addGestureRecognizer(tapGesture)
    }
}
