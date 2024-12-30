//
//  SelectionOptionViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/04/04.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine
import KakaoSDKNavi


final class SelectionOptionViewModel {
    //MARK: - Properties
    let type: SelectionType
    let settingUseCase: SettingUseCase
    
    let titlePublisher: CurrentValueSubject<String?, Never> = .init(nil)
    
    
    //MARK: Initializer
    init(type: SelectionType,
         settingUseCase: SettingUseCase) {
        self.type = type
        self.settingUseCase = settingUseCase
        
        setTitle()
    }
}

//MARK: - I/O & Error
extension SelectionOptionViewModel {
    enum SelectionType {
        case navigation
        case fuelType
    }
    
    struct SelectionOption: Hashable {
        let title: String
        let isSelected: Bool
    }
    
    struct SelectionResult {
        let toast: ToastModel
        let installURL: URL?
        
        struct ToastModel {
            let width: CGFloat
            let message: String
            let subTitle: String
        }
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let didSelectItem: AnyPublisher<SelectionOption, Never>
        let laterButtonTapped: AnyPublisher<Void, Never>
        let backgroundViewTapped: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let updateSelectionOptions: AnyPublisher<[SelectionOption], Never>
        let dismiss: AnyPublisher<Void, Never>
        let dismissWithSelectionResult: AnyPublisher<SelectionResult, Never>
    }
    
    func transform(input: Input) -> Output {
        return .init(
            updateSelectionOptions: updateSelectionOptionsPublisher(input: input),
            dismiss: dismissPublisher(input: input),
            dismissWithSelectionResult: dismissWithSelectionResultPublisher(input: input)
        )
    }
}


//MARK: - Make publisher
private extension SelectionOptionViewModel {
    func updateSelectionOptionsPublisher(input: Input) -> AnyPublisher<[SelectionOption], Never> {
        return input.viewDidLoad
            .map { [weak self] in
                guard let self,
                      let selectionOptions = try? selectionOptions() else {
                    return []
                }
                return selectionOptions
            }
            .eraseToAnyPublisher()
    }
    
    func dismissPublisher(input: Input) -> AnyPublisher<Void, Never> {
        return Publishers.Merge(
            input.laterButtonTapped,
            input.backgroundViewTapped
        ).compactMap { [weak self] in
            guard let self else {
                return nil
            }
            
            switch type {
            case .navigation:
                guard let navigationType: String = try? settingUseCase.load(type: .navigationType) else {
                    return
                }
                settingUseCase.save(navigationType, type: .navigationType)
            case .fuelType:
                guard let fuelType: String = try? settingUseCase.load(type: .fuelType) else {
                    return
                }
                settingUseCase.save(fuelType, type: .fuelType)
            }
        }
        .eraseToAnyPublisher()
    }
    
    func dismissWithSelectionResultPublisher(input: Input) -> AnyPublisher<SelectionResult, Never> {
        return input.didSelectItem
            .compactMap { [weak self] option in
                guard let self else {
                    return nil
                }
                return selectionResult(selectedOption: option)
            }
            .eraseToAnyPublisher()
    }
}


private extension SelectionOptionViewModel {
    func selectionOptions() throws -> [SelectionOption] {
        switch type {
        case .navigation:
            let navigationType: String = try settingUseCase.load(type: .navigationType)
            return SearchNavigation.allCases.map {
                return SelectionOption(
                    title: $0.displayName,
                    isSelected: $0.type == navigationType
                )
            }
            
        case .fuelType:
            let fuelType: String = try settingUseCase.load(type: .fuelType)
            return FuelType.allCases.map {
                return SelectionOption(
                    title: $0.displayName,
                    isSelected: $0.code == fuelType
                )
            }
        }
    }
    
    func setTitle() {
        switch type {
        case .navigation:
            titlePublisher.send("연동할 내비게이션을 선택해 주세요.")
        case .fuelType:
            titlePublisher.send("찾으시는 유종을 선택해 주세요.")
        }
    }
    
    func selectionResult(selectedOption option: SelectionOption) -> SelectionResult {
        let defaultSubTitle = "메뉴에서 언제든 변경하실 수 있습니다."
        
        switch type {
        case .navigation:
            let navigationType = SearchNavigation(displayName: option.title)
            settingUseCase.save(navigationType.type, type: .navigationType)
            
            let installURL = installURL()
            let navigation = SearchNavigation(displayName: option.title)
            let isKakaoMapOrTMap = navigation == .kakaoMap || navigation == .tMap
            
            let title = isKakaoMapOrTMap ? "\(navigation.displayName)으로" : "\(navigation.displayName)로"
            var subTitle = defaultSubTitle
            
            if installURL != nil {
                subTitle = isKakaoMapOrTMap ? "\(navigation.displayName)이" : "\(navigation.displayName)가"
                subTitle += " 설치되어 있지 않아 설치페이지로 이동합니다."
            }
            
            return .init(
                toast: .init(
                    width: installURL == nil ? 210 : 290,
                    message: "\(title) 길 안내를 제공합니다.\n\(subTitle)",
                    subTitle: subTitle
                ),
                installURL: installURL
            )
            
        case .fuelType:
            let fuelType = FuelType(displayName: option.title)
            settingUseCase.save(fuelType.code, type: .fuelType)
            
            return .init(
                toast: .init(
                    width: 210,
                    message: "선택하신 유종으로 탐색을 시작합니다.\n\(defaultSubTitle)",
                    subTitle: "메뉴에서 언제든 변경하실 수 있습니다."
                ),
                installURL: nil
            )
        }
    }
    
    func installURL() -> URL? {
        guard let naviType: String = try? settingUseCase.load(type: .navigationType) else {
            return nil
        }
        
        let searchNavigation = SearchNavigation(type: naviType)
        let coordinate = CoordinateSystem(x: nil, y: nil)
        
        let destinationURL: URL?
        let appStoreURL: URL?
        
        switch searchNavigation {
        case .tMap:
            let urlString = "tmap://?rGoName=테스트&rGoX=\(coordinate.tm.lng)&rGoY=\(coordinate.tm.lat)"
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            destinationURL = URL(string: encodedStr, encodingInvalidCharacters: false)
            appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/431589174", encodingInvalidCharacters: false)
            
        case .kakao:
            let destination = NaviLocation(name: "테스트", x: "\(NSNumber(value: coordinate.katec.x))", y: "\(NSNumber(value: coordinate.katec.y))")
            destinationURL = NaviApi.shared.navigateUrl(destination: destination, option: NaviOption(routeInfo: false))
            appStoreURL = NaviApi.webNaviInstallUrl
            
        case .kakaoMap:
            destinationURL = URL(string: "kakaomap://route?ep=\(coordinate.tm.lat),\(coordinate.tm.lng)&by=CAR", encodingInvalidCharacters: false)
            appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/304608425", encodingInvalidCharacters: false)
            
        case .naver:
            let urlString = "nmap://navigation?dlat=\(coordinate.tm.lat)&dlng=\(coordinate.tm.lng)&dname=테스트&appname=com.oilpricewhere.wheregasoline"
            let encodedStr = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            destinationURL = URL(string: encodedStr, encodingInvalidCharacters: false)
            appStoreURL = URL(string: "itms-apps://itunes.apple.com/app/311867728", encodingInvalidCharacters: false)
        }
        
        if let destinationURL,
           UIApplication.shared.canOpenURL(destinationURL) {
            return nil
        } else {
            return appStoreURL
        }
    }
}
