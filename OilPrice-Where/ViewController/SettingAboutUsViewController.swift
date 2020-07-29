//
//  SettingAboutUsViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

class SettingAboutUsViewController: UIViewController {
   static let identifier = "SettingAboutUsViewController"
   @IBOutlet private weak var tableView: UITableView!
   
   override func viewDidLoad() {
      super.viewDidLoad()
   }
}

extension SettingAboutUsViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return 3
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      guard let cell = tableView.dequeueReusableCell(withIdentifier: AboutUsTableViewCell.identifier,
                                                     for: indexPath) as? AboutUsTableViewCell else { fatalError() }
      cell.selectionStyle = .none
      var target = ("", "")
      
      switch indexPath.row {
      case 0:
         target.0 = "Wargi"
         target.1 = "github.com/wargi"
      case 1:
         target.0 = "Himchan park"
         target.1 = "github.com/himchanPark"
      default:
         target.0 = "Solchan ahn"
         target.1 = "github.com/solchan87"
      }
      
      cell.nameLabel.text = target.0
      cell.linkLabel.text = target.1
      
      return cell
   }
}

extension SettingAboutUsViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 117
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      if indexPath.row == 0 {
         if let url = URL(string: "https://www.github.com/wargi") {
            if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url,
                                         options: [:],
                                         completionHandler: nil)
            }
         }
      } else if indexPath.row == 1 {
         if let url = URL(string: "https://github.com/himchanPark") {
            if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url,
                                         options: [:],
                                         completionHandler: nil)
            }
         }
      } else {
         if let url = URL(string: "https://github.com/solchan87") {
            if UIApplication.shared.canOpenURL(url) {
               UIApplication.shared.open(url,
                                         options: [:],
                                         completionHandler: nil)
            }
         }
      }
   }
}
