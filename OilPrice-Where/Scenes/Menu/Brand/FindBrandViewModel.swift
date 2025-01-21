//
//  FindBrandViewModel.swift
//  OilPrice-Where
//
//  Created by 박상욱 on 2020/07/26.
//  Copyright © 2020 sangwook park. All rights reserved.
//

import Combine
import Foundation


final class FindBrandViewModel {
    
    private var cancellable = Set<AnyCancellable>()
    private let settingUseCase: SettingUseCase
    
    let brandSubject: CurrentValueSubject<[Brand], Never> = .init([])
    
    init(settingUseCase: SettingUseCase) {
        self.settingUseCase = settingUseCase
    }
}


extension FindBrandViewModel {
    struct Brand: Hashable {
        let code: String
        let name: String
        var isSearchedBrand: Bool = true
    }
    
    struct Action {
        var viewDidLoad: AnyPublisher<Void, Never>
        var selectedBrand: AnyPublisher<Brand, Never>
    }
    
    func bind(action: Action) {
        action.viewDidLoad
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                let findBrands = loadFindBrands()
                brandSubject.send(findBrands)
            }
            .store(in: &cancellable)
        
        action.selectedBrand
            .sink { [weak self] brand in
                guard let self else {
                    return
                }
                // 선택된 상태 저장
                saveFindBrand(brand)
                
                let findBrands = loadFindBrands()
                brandSubject.send(findBrands)
            }
            .store(in: &cancellable)
    }
}


private extension FindBrandViewModel {
    func loadFindBrands() -> [Brand] {
        var findBrands: [Brand] = StationBrand.allCases.map {
            .init(code: $0.code, name: $0.name)
        }
        
        do {
            let storedFindBrand: [String] = try settingUseCase.load(type: .findBrands)
            findBrands.enumerated().forEach { index, brand in
                let currentBrand = StationBrand(code: brand.code)
                
                if currentBrand == .all {
                    // 저장된 탐색 브랜수와 전체 브랜수(여기서 -1은 전체탐색을 의미하는 All을 뺀 값) 일치하면 전체 탐색
                    let isSearchAllBrand = storedFindBrand.count == (findBrands.count - 1)
                    findBrands[index].isSearchedBrand = isSearchAllBrand
                } else {
                    findBrands[index].isSearchedBrand = storedFindBrand.contains(brand.code)
                }
            }
        } catch {
            LogUtil.e(error.localizedDescription)
        }
        
        return findBrands
    }
    
    func saveFindBrand(_ brand: Brand) {
        // 선택 Case => 전체 탐색 여부
        let selectedStationBrand = StationBrand(code: brand.code)
        
        let saveAllBrands = StationBrand.allCases
            .filter { $0 != .all }
            .map { $0.code }
        
        if selectedStationBrand == .all {
            // 전체 탐색
            if brand.isSearchedBrand {
                settingUseCase.save(saveAllBrands, type: .findBrands)
            }
            // 탐색 안함
            else {
                let noSearchBrands: [String] = []
                settingUseCase.save(noSearchBrands, type: .findBrands)
            }
        } else {
            let storeFindBrands: [String] = brandSubject.value
                .compactMap {
                    // 전체 탐색은 저장하지 않음
                    if StationBrand(code: $0.code) == .all { return nil }
                    
                    if brand.code == $0.code {
                        return brand.isSearchedBrand ? brand.code : nil
                    } else {
                        return $0.isSearchedBrand ? $0.code : nil
                    }
                }
            
            settingUseCase.save(storeFindBrands, type: .findBrands)
        }
    }
}
