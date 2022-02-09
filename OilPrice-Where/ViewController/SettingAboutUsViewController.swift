//
//  SettingAboutUsViewController.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit

enum SelectGitCell: Int {
   case wargi = 0
   case himchan = 1
   case solchan = 2
}

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
      guard let selectCellType = SelectGitCell(rawValue: indexPath.row),
         let cell = tableView.dequeueReusableCell(withIdentifier: AboutUsTableViewCell.identifier,
                                                  for: indexPath) as? AboutUsTableViewCell else { fatalError() }
      cell.selectionStyle = .none
      var target: (name: String, link: String) = ("", "")
      
      switch selectCellType {
      case .wargi:
         target.name = "Wargi"
         target.link = "github.com/wargi"
      case .himchan:
         target.name = "Himchan park"
         target.link = "github.com/himchanPark"
      case .solchan:
         target.name = "Solchan ahn"
         target.link = "github.com/solchan87"
      }
      
      cell.nameLabel.text = target.name
      cell.linkLabel.text = target.link
      
      return cell
   }
}

extension SettingAboutUsViewController: UITableViewDelegate {
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return 117
   }
   
   func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      guard let selectCellType = SelectGitCell(rawValue: indexPath.row) else { return }
      
      var targetUrlString = ""
      
      switch selectCellType {
      case .wargi:
         targetUrlString = "https://www.github.com/wargi"
      case .himchan:
         targetUrlString = "https://github.com/himchanPark"
      case .solchan:
         targetUrlString = "https://github.com/solchan87"
      }
      
      if let url = URL(string: targetUrlString) {
         if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
         }
      }
   }
}
