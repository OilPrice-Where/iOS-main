//
//  UIAlertViewController+.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit


extension UIAlertController {
    static var okAction: UIAlertAction {
        .init(title: "확인", style: .default)
    }
    
    static func createAlertContoller(title: String,
                                     message: String,
                                     style: UIAlertControllerStyle = .alert,
                                     actions: [UIAlertAction] = [okAction]) -> UIAlertController {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: style
        )
        
        actions.forEach {
            alert.addAction($0)
        }
        
        return alert
    }
}
