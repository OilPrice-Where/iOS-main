//
//  SettingAboutUsVC.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/28.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import UIKit
import SnapKit
import Then

enum SelectGitCell: Int {
    case wargi = 0
    case himchan = 1
    case solchan = 2
}

final class SettingAboutUsVC: UIViewController {
    //MARK: - Properties
    lazy var tableView = UITableView().then {
        $0.dataSource = self
        $0.delegate = self
        $0.alwaysBounceVertical = false
        $0.alwaysBounceHorizontal = false
        $0.showsVerticalScrollIndicator = false
        $0.showsHorizontalScrollIndicator = false
        $0.backgroundColor = Asset.Colors.tableViewBackground.color
        AboutUsTableViewCell.register($0)
    }
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.statusBarUIView?.backgroundColor = Asset.Colors.mainColor.color
    }
    
    //MARK: - Configure UI
    func makeUI() {
        navigationItem.title = "About Us"
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension SettingAboutUsVC: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let selectCellType = SelectGitCell(rawValue: indexPath.row) else { return UITableViewCell() }
        let cell = tableView.dequeueReusableCell(withType: AboutUsTableViewCell.self, for: indexPath)
        
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

extension SettingAboutUsVC: UITableViewDelegate {
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
            targetUrlString = "https://www.github.com/himchanPark"
        case .solchan:
            targetUrlString = "https://www.github.com/solchan87"
        }
        
        if let url = URL(string: targetUrlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
    }
}
