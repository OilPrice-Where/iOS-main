//
//  UIReusable+Extension.swift
//  OilPrice-Where
//
//  Created by wargi_p on 2021/12/16.
//  Copyright © 2021 sangwook park. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    static var id: String {
        return "\(Self.self)"
    }
}

extension UITableViewCell {
    static func register(_ target: UITableView) {
        target.register(Self.self, forCellReuseIdentifier: Self.id)
    }
}

extension UICollectionViewCell {
    static func register(_ target: UICollectionView) {
        target.register(Self.self, forCellWithReuseIdentifier: Self.id)
    }
}

extension UICollectionView {
    func dequeueReusableCell<T: UICollectionViewCell>(withType type: T.Type, indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withReuseIdentifier: type.id, for: indexPath) as? T else { fatalError() }
        
        return cell
    }
}

extension UITableView {
    func dequeueReusableCell<T: UITableViewCell>(withType type: T.Type, for indexPath: IndexPath) -> T {
        guard let cell = self.dequeueReusableCell(withIdentifier: type.id, for: indexPath) as? T else { fatalError() }
        
        return cell
    }
}
