//
//  WidgetFavoriteCollectionViewCell.swift
//  FavoriteWidgetExtension
//
//  Created by 박상욱 on 2020/08/25.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

class WidgetFavoriteCollectionViewCell: UICollectionViewCell {
   static let identifier = "WidgetFavoriteCollectionViewCell"
   @IBOutlet private weak var brandImageView: UIImageView!
   @IBOutlet private weak var oilTypeLabel: UILabel!
   @IBOutlet private weak var oilPriceLabel: UILabel!
   @IBOutlet weak var backView: UIView!
}
