//
//  StationInfoVC.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/02/10.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import Foundation
import Then
import SnapKit
import UIKit
import RxSwift
import RxCocoa

//MARK: Station Info VC
final class StationInfoVC: UIViewController {
    //MARK: - Properties
    let bag = DisposeBag()
    var stationInfoView = StationInfoView()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        rxBind()
    }
    
    //MARK: - Make UI
    func makeUI() {
        view.backgroundColor = .white
        view.addSubview(stationInfoView)
        
        stationInfoView.snp.makeConstraints {
            $0.left.right.equalToSuperview()
            $0.top.equalToSuperview()
            $0.height.equalTo(178)
        }
    }
    
    //MARK: - Rx Binding..
    func rxBind() {
        
    }
}
