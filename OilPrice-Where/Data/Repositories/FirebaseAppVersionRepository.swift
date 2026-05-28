//
//  FirebaseAppVersionRepository.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase


final class FirebaseAppVersionRepository: AppVersionRepository {
    func fetchCurrentAppVersion() async throws -> DatabaseVersionModel {
        do {
            let systemRef = Database.database().reference()
            let versionPath = systemRef.child(Constants.FirebasePath.Version.root)
            let versionData: NSDictionary = try await fetchSnapShotValue(reference: versionPath)
            
            guard
                let versionDic = versionData as? [String: String],
                let latestVersionCode = versionDic[Constants.Parameter.latestVersionCode],
                let latestVersionName = versionDic[Constants.Parameter.latestVersionName],
                let minimumVersionCode = versionDic[Constants.Parameter.minimumVersionCode],
                let minimumVersionName = versionDic[Constants.Parameter.minimumVersionName]
            else {
                throw FirebaseError.emptyData
            }
            
            return DatabaseVersionModel(
                latestVersionCode: latestVersionCode,
                latestVersionName: latestVersionName,
                minimumVersionCode: minimumVersionCode,
                minimumVersionName: minimumVersionName
            )
        } catch {
            throw error
        }
    }
}


private extension FirebaseAppVersionRepository {
    func fetchSnapShotValue<T>(reference path: DatabaseReference) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            path.observeSingleEvent(of: DataEventType.value, with: { snapshot in
                guard let averageCost = snapshot.value as? T else {
                    continuation.resume(throwing: FirebaseError.emptyData)
                    return
                }
                continuation.resume(returning: averageCost)
            }, withCancel: { error in
                continuation.resume(throwing: error)
            })
        }
    }
    
    enum Constants {
        enum Parameter {
            static let latestVersionCode = "lastest_version_code"
            static let latestVersionName = "lastest_version_name"
            static let minimumVersionCode = "minimum_version_code"
            static let minimumVersionName = "minimum_version_name"
        }
        
        enum FirebasePath {
            enum Version {
                static let root = "version"
            }
        }
    }
}
