import ProjectDescription


// MARK: - 커스텀 빌드 컨피그 (원본 pbxproj 4종 그대로)
extension ConfigurationName {
    static let debugProd: ConfigurationName = "Debug-Prod"
    static let releaseProd: ConfigurationName = "Release-Prod"
    static let debugInHouse: ConfigurationName = "Debug-InHouse"
    static let releaseInHouse: ConfigurationName = "Release-InHouse"
}

// MARK: - 프로젝트 공통 설정
let appSettings: Settings = .settings(
    base: [
        "SWIFT_VERSION": "5.0",
        "CODE_SIGN_STYLE": "Automatic",
        "DEVELOPMENT_TEAM": "3ZS2532XM8",
        "MARKETING_VERSION": "2.9.4",
        "CURRENT_PROJECT_VERSION": "1",
        "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
    ],
    configurations: [
        .debug(name: .debugProd, settings: ["OTHER_SWIFT_FLAGS": "-DPROD -DDEBUG"], xcconfig: "Configurations/Prod-Config.xcconfig"),
        .release(name: .releaseProd, settings: ["OTHER_SWIFT_FLAGS": "-DPROD -DRELEASE"], xcconfig: "Configurations/Prod-Config.xcconfig"),
        .debug(name: .debugInHouse, settings: ["OTHER_SWIFT_FLAGS": "-DINHOUSE -DDEBUG"], xcconfig: "Configurations/InHouse-Config.xcconfig"),
        .release(name: .releaseInHouse, settings: ["OTHER_SWIFT_FLAGS": "-DINHOUSE -DRELEASE"], xcconfig: "Configurations/InHouse-Config.xcconfig")
    ]
)

//MARK: - Test Target
let appTests: Target = .target(
    name: "OilWhereTests",
    destinations: .iOS,
    product: .unitTests,
    bundleId: "com.OilPriceWhere.wheregasolineTests",
    deploymentTargets: .iOS("18.0"),
    infoPlist: .default,
    sources: ["OilPrice-Where/Tests/**"],
    resources: [],
    dependencies: [.target(name: "OilWhere")]
)

//MARK: - App Target
let app: Target = .target(
    name: "OilWhere",
    destinations: .iOS,
    product: .app,
    bundleId: "$(X_BUNDLE_ID)",
    deploymentTargets: .iOS("18.0"),
    infoPlist: .file(path: "OilPrice-Where/SupportFiles/Info.plist"),
    sources: [
        .glob("OilPrice-Where/**", excluding: ["OilPrice-Where/Tests/**"])
    ],
    resources: [
        "OilPrice-Where/Resources/**",
        "OilPrice-Where/SupportFiles/GoogleService-Info.plist",
        "OilPrice-Where/SupportFiles/UserInfo.plist",
        "AppSettings.plist",
    ],
    entitlements: .file(path: "OilPrice-Where/Entitlements/OilPrice-Where.entitlements"),
    dependencies: [
        .xcframework(path: "TMap/TMapSDK.xcframework", status: .required),
        .xcframework(path: "TMap/VSMSDK.xcframework", status: .required),
        .external(name: "SnapKit"),
        .external(name: "Moya"),
        .external(name: "Toast"),
        .external(name: "FirebaseAnalytics"),
        .external(name: "FirebaseDatabase"),
        .external(name: "FirebaseStorage"),
        .external(name: "FloatingPanel"),
        .external(name: "SideMenu"),
        .external(name: "Then"),
        .external(name: "NMapsMap"),
        .external(name: "KakaoSDK"),
    ],
    coreDataModels: [
        .coreDataModel("OilPrice-Where/Data/PersistentStorages/CoreDataStorage/DataModel.xcdatamodeld")
    ]
)

// MARK: - Schemes
let devScheme: Scheme = .scheme(
    name: "OilWhereInHouse",
    buildAction: .buildAction(targets: ["OilWhere"]),
    testAction: .targets(["OilWhereTests"], configuration: .debugInHouse),
    runAction: .runAction(configuration: .debugInHouse),
    archiveAction: .archiveAction(configuration: .releaseInHouse),
    profileAction: .profileAction(configuration: .releaseInHouse),
    analyzeAction: .analyzeAction(configuration: .releaseInHouse)
)

let prodScheme: Scheme = .scheme(
    name: "OilWhere",
    buildAction: .buildAction(targets: ["OilWhere"]),
    testAction: .targets(["OilWhereTests"], configuration: .debugProd),
    runAction: .runAction(configuration: .debugProd),
    archiveAction: .archiveAction(configuration: .releaseProd),
    profileAction: .profileAction(configuration: .releaseProd),
    analyzeAction: .analyzeAction(configuration: .releaseProd)
)


// MARK: - Project
let project = Project(
    name: "iOS-main",
    settings: appSettings,
    targets: [app, appTests],
    schemes: [devScheme, prodScheme]
)
