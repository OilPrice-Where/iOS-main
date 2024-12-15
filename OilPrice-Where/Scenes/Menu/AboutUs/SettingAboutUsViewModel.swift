//
//  SettingAboutUsViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 1/19/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Combine
import Foundation


final class SettingAboutUsViewModel {
    
    let aboutUsPublisher: CurrentValueSubject<[AboutMe], Never> = .init([
        .init(
            name: "Wargi",
            githubLink: "github.com/wargi",
            githubUrl: "https://www.github.com/wargi"
        ),
        .init(
            name: "Himchan park",
            githubLink: "github.com/himchanPark",
            githubUrl: "https://www.github.com/himchanPark"
        ),
        .init(
            name: "Solchan ahn",
            githubLink: "github.com/solchan87",
            githubUrl: "https://www.github.com/solchan87"
        )
    ])
}


extension SettingAboutUsViewModel {
    struct AboutMe: Hashable {
        var name: String
        var githubLink: String
        var githubUrl: String
    }
    
    struct Input {
        var didSelectItem: AnyPublisher<AboutMe, Never>
    }
    
    struct Output {
        var openLink: AnyPublisher<URL, Never>
    }
    
    func transform(input: Input) -> Output {
        let openLink: AnyPublisher<URL, Never> = input.didSelectItem
            .compactMap { aboutMe in
                guard let targetUrl = URL(string: aboutMe.githubUrl, encodingInvalidCharacters: false) else {
                    return nil
                }
                return targetUrl
            }
            .eraseToAnyPublisher()
        
        return .init(
            openLink: openLink
        )
    }
}
