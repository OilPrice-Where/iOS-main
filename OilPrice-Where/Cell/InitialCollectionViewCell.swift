//
//  InitialCollectionViewCell.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/08/03.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

class InitialCollectionViewCell: UICollectionViewCell {
   static let identifier = "InitialCollectionViewCell"
   @IBOutlet private weak var imageView: UIImageView!
   @IBOutlet private weak var typeLabel: UILabel!
   
   func configure(initialOilType: InitialOilType) {
      imageView.image = initialOilType.1
      typeLabel.text = initialOilType.0
   }
}
