//
//  SearchPOIStorage.swift
//  OilPrice-Where
//
//  Created by wargi on 2/1/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol SearchPOIStorage {
    func fetchSearchPOIs() -> [SearchPOI]
    @discardableResult
    func saveSearch(poi: SearchPOI) async throws -> SearchPOI
    func removeSearch(poi: SearchPOI) async throws
}
