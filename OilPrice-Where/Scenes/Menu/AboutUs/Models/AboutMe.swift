//
//  AboutMe.swift
//  OilPrice-Where
//
//  Created by wargi on 11/12/23.
//  Copyright © 2023 sangwook park. All rights reserved.
//

import Foundation


enum AboutMe: Int,CaseIterable {
    case wargi = 0
    case himchan
    case solchan
    
    var name: String {
        switch self {
        case .wargi:
            "Wargi"
        case .himchan:
            "Himchan park"
        case .solchan:
            "Solchan ahn"
        }
    }
    
    var link: String {
        switch self {
        case .wargi:
            "github.com/wargi"
        case .himchan:
            "github.com/wargi"
        case .solchan:
            "github.com/solchan87"
        }
    }
}
