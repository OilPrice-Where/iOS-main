//
//  UIScreen+.swift
//  OilPrice-Where
//
//  Created by wargi on 2/2/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import UIKit


extension UIScreen {
    static var current: UIScreen? {
        UIWindow.current?.screen
    }
    
    static var screenWidth: CGFloat {
        UIScreen.current?.bounds.width ?? .zero
    }
    
    static var screenHeight: CGFloat {
        UIScreen.current?.bounds.height ?? .zero
    }
}
