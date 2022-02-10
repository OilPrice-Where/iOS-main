//
//  ViewModelBindableType.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//
import UIKit

protocol ViewModelBindableType {
   associatedtype ViewModelType
   
   var viewModel: ViewModelType! { get set }
   func bindViewModel()
}

extension ViewModelBindableType where Self: UIViewController {
   var storyboard: UIStoryboard {
      return UIStoryboard(name: "Main", bundle: nil)
   }
   
   mutating func bind(viewModel: Self.ViewModelType) {
      self.viewModel = viewModel
      loadViewIfNeeded()
      
      bindViewModel()
   }
}
