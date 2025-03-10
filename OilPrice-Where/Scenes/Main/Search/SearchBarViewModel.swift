//
//  SearchBarViewModel.swift
//  OilPrice-Where
//
//  Created by wargi on 2022/10/30.
//  Copyright © 2022 sangwook park. All rights reserved.
//

import UIKit
import Combine


//MARK: SearchBarViewModel
final class SearchBarViewModel {
    //MARK: - Properties
    private var cancellables = Set<AnyCancellable>()

    private let searchPOIStorage: SearchPOIStorage
    
    private let recentSearchResultPublisher: CurrentValueSubject<[SearchPOI], Never> = .init([])
    
    
    //MARK: Initializer
    init(searchPOIStorage: SearchPOIStorage) {
        self.searchPOIStorage = searchPOIStorage
    }
    
    deinit {
        cancellables.removeAll()
    }
}


//MARK: - I/O & transform
extension SearchBarViewModel {
    struct SearchResultItem: Hashable {
        let searchText: String
        let poi: SearchPOI
    }
    
    struct Input {
        let viewDidLoad: AnyPublisher<Void, Never>
        let inputSearchText: AnyPublisher<String?, Never>
        let didTapPOI: AnyPublisher<SearchPOI, Never>
        let didTapDeletePOI: AnyPublisher<SearchPOI, Never>
        let didTapRemoveAllPOI: AnyPublisher<Void, Never>
    }
    
    struct Output {
        let recentSearchResult: AnyPublisher<[SearchPOI], Never>
        let searchKeywordResult: AnyPublisher<[SearchResultItem], Never>
        let selectedPOIResult: AnyPublisher<SearchPOI, Never>
    }
    
    func transform(input: Input) -> Output {
        bindActions(input: input)
        
        return .init(
            recentSearchResult: recentSearchResultPublisher.eraseToAnyPublisher(),
            searchKeywordResult: searchKeywordResultPublisher(input: input),
            selectedPOIResult: selectedPOIResultPublisher(input: input)
        )
    }
}

//MARK: Bind
private extension SearchBarViewModel {
    func bindActions(input: Input) {
        input.viewDidLoad
            .sink { [weak self] _ in
                guard let self else {
                    return
                }
                let searchPOIs = searchPOIStorage.fetchSearchPOIs()
                recentSearchResultPublisher.send(searchPOIs)
            }
            .store(in: &cancellables)
        
        input.didTapDeletePOI
            .sink { [weak self] poi in
                guard let self else { return }
                
                Task {
                    do {
                        try await self.searchPOIStorage.removeSearch(poi: poi)
                        let searchPOIs = self.searchPOIStorage.fetchSearchPOIs()
                        self.recentSearchResultPublisher.send(searchPOIs)
                    } catch {
                        LogUtil.e("검색 기록 삭제 실패: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)
        
        input.didTapRemoveAllPOI
            .sink { [weak self] poi in
                guard let self else {
                    return
                }
                
                Task {
                    do {
                        let searchPOIs = self.searchPOIStorage.fetchSearchPOIs()
                        try await withThrowingTaskGroup(of: Void.self) { group in
                            searchPOIs.forEach { poi in
                                group.addTask {
                                    try await self.searchPOIStorage.removeSearch(poi: poi)
                                }
                            }
                        }
                        self.recentSearchResultPublisher.send([])
                    } catch {
                        LogUtil.e("전체 검색 기록 삭제 실패: \(error.localizedDescription)")
                    }
                }
            }
            .store(in: &cancellables)
    }
}


//MARK: Make Publisher
private extension SearchBarViewModel {
    func searchKeywordResultPublisher(input: Input) -> AnyPublisher<[SearchResultItem], Never> {
        input.inputSearchText
            .debounce(for: 0.5, scheduler: DispatchQueue.main)
            .removeDuplicates()
            .compactMap { $0 }
            .filter { $0.isNotEmpty }
            .flatMap { searchText in
                Future<[SearchResultItem], Never> { promise in
                    Task {
                        let searchPOIs = await LocationManager.shared.fetchSearchPOIs(keyword: searchText)
                        let searchResultItems = searchPOIs.map {
                            SearchResultItem(
                                searchText: searchText,
                                poi: $0
                            )
                        }
                        promise(.success(searchResultItems))
                    }
                }
            }
            .eraseToAnyPublisher()
    }
    
    func selectedPOIResultPublisher(input: Input) -> AnyPublisher<SearchPOI, Never> {
        input.didTapPOI
            .map { [weak self] poi in
                Task {
                    try await self?.searchPOIStorage.saveSearch(poi: .init(
                        name: poi.name,
                        address: poi.address,
                        coordinate: poi.coordinate,
                        insertDate: Date()
                    ))
                }
                return poi
            }
            .eraseToAnyPublisher()
    }
}
