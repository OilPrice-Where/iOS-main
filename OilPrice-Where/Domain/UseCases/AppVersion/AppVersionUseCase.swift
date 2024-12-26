//
//  AppVersionUseCase.swift
//  OilPrice-Where
//
//  Created by wargi on 1/26/25.
//  Copyright © 2025 sangwook park. All rights reserved.
//

import Foundation


protocol AppVersionUseCase {
    /// 최신 앱 버전을 확인하고, 앱 업데이트 상태를 반환
    func checkAndUpdateAppVersion() async -> AppUpdateStatus
}


final class AppVersionUseCaseImpl: AppVersionUseCase {
    private let appVersionRepository: AppVersionRepository
    
    init(appVersionRepository: AppVersionRepository) {
        self.appVersionRepository = appVersionRepository
    }
    
    func checkAndUpdateAppVersion() async -> AppUpdateStatus {
        guard
            let versionModel = try? await appVersionRepository.fetchCurrentAppVersion(),
            let infoDic = Bundle.main.infoDictionary,
            let bundleVersion = infoDic[Constants.BundleInfoParameters.version] as? String,
            let shortVersionString = infoDic[Constants.BundleInfoParameters.shortVersionString] as? String,
            let buildVersion = Int(bundleVersion),
            let minimumVersion = Int(versionModel.minimumVersionCode),
            let lastestVersion = Int(versionModel.latestVersionCode)
        else {
            return Constants.AppUpdateStatusPreset.versionInfoUnavailable
        }
        
        if (shortVersionString < versionModel.minimumVersionName) ||
            (shortVersionString == versionModel.minimumVersionName &&
             buildVersion < minimumVersion) {
            return Constants.AppUpdateStatusPreset.forceUpdate
        } else if shortVersionString < versionModel.latestVersionName ||
                    (shortVersionString == versionModel.latestVersionName &&
                     buildVersion < lastestVersion) {
            return Constants.AppUpdateStatusPreset.optionalUpdate
        } else {
            return Constants.AppUpdateStatusPreset.upToDate(currentVersion: versionModel.latestVersionName)
        }
    }
}

private extension AppVersionUseCaseImpl {
    enum Constants {
        enum AppUpdateStatusPreset {
            private static let appID: String = "1435350344"
            private static let appURL: String = "itms-apps://itunes.apple.com/app/itunes-u/id\(appID)"
            
            static func upToDate(currentVersion: String) -> AppUpdateStatus {
                return .upToDate(
                    title: "최신 버전을 사용 중입니다😍",
                    message: "설치된 버전 정보: \(currentVersion)"
                )
            }
            
            static let optionalUpdate: AppUpdateStatus = .optionalUpdate(
                title: "새로운 버전 알림😉",
                message: "새로운 기능을 이용하려면 업데이트 해주세요!\n",
                appURL: appURL
            )
            
            static let forceUpdate: AppUpdateStatus = .forcedUpdate(
                title: "필수 업데이트 알림🥲",
                message: "최신 버전의 앱으로 업데이트해주세요.\n서비스 이용을 위해 앱을 업데이트 페이지로 이동합니다.",
                appURL: appURL
            )
            
            static let versionInfoUnavailable: AppUpdateStatus = .versionInfoUnavailable(
                title: "버전 정보를 불러올 수 없습니다😭",
                message: "네트워크 상태를 확인하거나 나중에 다시 시도해주세요."
            )
        }
        
        enum BundleInfoParameters {
            static let version: String = "CFBundleVersion"
            static let shortVersionString: String = "CFBundleShortVersionString"
        }
    }
}
