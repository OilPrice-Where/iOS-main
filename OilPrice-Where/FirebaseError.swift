//
//  FirebaseError.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


enum FirebaseError: Error, LocalizedError {
    case emptyData
    
    var errorDescription: String? {
        switch self {
        case .emptyData:
            return "데이터가 없습니다."
        }
    }
}
