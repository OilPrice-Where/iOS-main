//
//  CommonViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import Combine


class CommonViewController: UIViewController {
    var cancellable = Set<AnyCancellable>()
    var reachability: Reachability? = Reachability() //Network
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setNetworkSetting()
    }
    
    deinit {
        LogUtil.d(self)
        reachability?.stopNotifier()
        reachability = nil
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        LogUtil.d(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setNetworkSetting() {
        do {
            try reachability?.startNotifier()
        } catch {
            LogUtil.e(error.localizedDescription)
        }
    }
}
