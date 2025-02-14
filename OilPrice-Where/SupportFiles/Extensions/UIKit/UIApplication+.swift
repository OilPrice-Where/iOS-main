//
//  UIApplication+.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/16.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import UIKit

extension UIApplication {
    public var customKeyWindow: UIWindow? {
        return UIApplication.shared.connectedScenes
                .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
                .first { $0.isKeyWindow }
    }
    
    var statusBarUIView: UIView? {
        if #available(iOS 13.0, *) {
            let tag = 3848245
            if let statusBar = customKeyWindow?.viewWithTag(tag) {
                return statusBar
            } else {
                let height = customKeyWindow?.windowScene?.statusBarManager?.statusBarFrame ?? .zero
                let statusBarView = UIView(frame: height)
                statusBarView.tag = tag
                statusBarView.layer.zPosition = 999999
                
                customKeyWindow?.addSubview(statusBarView)
                return statusBarView
            }
        } else  if responds(to: Selector(("statusBar"))) {
            return value(forKey: "statusBar") as? UIView
        } else {
            return nil
        }
    }
}
