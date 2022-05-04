//
//  UIColor+.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/05/05.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        var hexString = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if hexString.hasPrefix("#") {
            hexString = String(hexString.dropFirst())
        }
        
        let scanner = Scanner(string: hexString)

        var color: UInt64 = 0
        scanner.scanHexInt64(&color)

        let red = CGFloat((color & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((color & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(color & 0x0000FF) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    func toHexString() -> String {
        var r:CGFloat = 0
        var g:CGFloat = 0
        var b:CGFloat = 0
        var a:CGFloat = 0
        getRed(&r, green: &g, blue: &b, alpha: &a)
        let rgb:Int = (Int)(r*255)<<16 | (Int)(g*255)<<8 | (Int)(b*255)<<0
        return String(format:"#%06x", rgb)
    }
}
